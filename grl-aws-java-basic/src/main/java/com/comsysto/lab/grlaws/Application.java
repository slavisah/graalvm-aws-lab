package com.comsysto.lab.grlaws;

import java.io.IOException;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectReader;
import com.fasterxml.jackson.databind.ObjectWriter;

public class Application {

    private static final Logger log = LogManager.getLogger(Application.class);

    private static Class<? extends RequestHandler<?, ?>> handlerClass;
    private static ObjectMapper objectMapper = new ObjectMapper();
    private static ObjectReader objectReader;
    private static ObjectWriter objectWriter;

    public Application() throws Exception {
        objectMapper = new ObjectMapper()
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .configure(MapperFeature.ACCEPT_CASE_INSENSITIVE_PROPERTIES, true);
        String handler = CustomRuntimeApi.handler();
        handlerClass = (Class<? extends RequestHandler<?, ?>>)Class.forName(handler);
        Method handlerMethod = discoverHandlerMethod(handlerClass);
        objectReader = objectMapper.readerFor(handlerMethod.getParameterTypes()[0]);
        objectWriter = objectMapper.writerFor(handlerMethod.getReturnType());
    }

    public static void main(String[] args) throws Exception {
        new Application().bootstrap();
    }

    public void bootstrap() {
        log.debug("Bootstrapping the lambda...");
        AtomicBoolean running = new AtomicBoolean(true);
        ObjectReader cognitoIdReader = objectMapper.readerFor(CognitoIdentity.class);
        ObjectReader clientCtxReader = objectMapper.readerFor(ClientContext.class);

        new Thread(() -> {

            try {
                URL requestUrl = CustomRuntimeApi.invocationNext();
                while (running.get()) {
                    HttpURLConnection requestConnection = (HttpURLConnection) requestUrl.openConnection();
                    String requestId = requestConnection.getHeaderField(CustomRuntimeApi.LAMBDA_RUNTIME_AWS_REQUEST_ID);
                    Object response;
                    try {
                        Object val = objectReader.readValue(requestConnection.getInputStream());
                        RequestHandler handler = handlerClass.newInstance();
                        response = handler.handleRequest(val,
                                new CustomRuntimeContext(requestConnection, cognitoIdReader, clientCtxReader));
                    } catch (Exception e) {
                        log.error("Failure while running lambda", e);

                        postResponse(CustomRuntimeApi.invocationError(requestId),
                                new Error(e.getClass().getName(), e.getMessage()), objectMapper);
                        continue;
                    }

                    postResponse(CustomRuntimeApi.invocationResponse(requestId), response, objectMapper);
                }
            } catch (Exception e) {
                try {
                    log.error("First step error", e);
                    postResponse(CustomRuntimeApi.initError(), new Error(e.getClass().getName(), e.getMessage()),
                            objectMapper);
                } catch (Exception ex) {
                    log.error("Error sending failed!", ex);
                }
            }
        }, "Lambda").start();
    }

    private void postResponse(URL url, Object response, ObjectMapper mapper) throws IOException {
        HttpURLConnection responseConnection = (HttpURLConnection) url.openConnection();
        responseConnection.setDoOutput(true);
        responseConnection.setRequestMethod("POST");
        mapper.writeValue(responseConnection.getOutputStream(), response);
        while (responseConnection.getInputStream().read() != -1) {}
    }

    private Method discoverHandlerMethod(Class<? extends RequestHandler<?, ?>> handlerClass) {
        final Method[] methods = handlerClass.getMethods();
        Method method = null;
        for (int i = 0; i < methods.length && method == null; i++) {
            if (methods[i].getName().equals("handleRequest")) {
                final Class<?>[] types = methods[i].getParameterTypes();
                if (types.length == 2 && !types[0].equals(Object.class)) {
                    method = methods[i];
                }
            }
        }
        if (method == null) {
            method = methods[0];
        }
        return method;
    }
}