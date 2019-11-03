package com.comsysto.lab.grlaws;

import java.io.IOException;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Application {

    private static final String REQUEST_ID_HEADER_NAME = "lambda-runtime-aws-request-id";
    private static final String RUNTIME_API_ENDPOINT_VARIABLE_NAME = "AWS_LAMBDA_RUNTIME_API";
    private static final String HANDLER_VARIABLE_NAME = "_HANDLER";

    public static void main(String[] args) {
        CloseableHttpClient httpClient = HttpClients.createDefault();
        ObjectMapper mapper = new ObjectMapper().configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        String runtimeApiEndpoint = System.getenv(RUNTIME_API_ENDPOINT_VARIABLE_NAME);
        String handler = System.getenv(HANDLER_VARIABLE_NAME);
        try {
            RequestHandler<ApiGatewayRequest, ApiGatewayResponse> handlerInstance = (RequestHandler<ApiGatewayRequest, ApiGatewayResponse>)Class.forName(handler).newInstance();
            while (true) {
                HttpGet invocation = new HttpGet(String.format("http://%s/2018-06-01/runtime/invocation/next", runtimeApiEndpoint));
                try (CloseableHttpResponse invocationResponse = httpClient.execute(invocation)) {
                    HttpEntity entity = invocationResponse.getEntity();
                    Header headers = invocationResponse.getFirstHeader(REQUEST_ID_HEADER_NAME);
                    String requestId = headers != null ? headers.getValue() : null;
                    ApiGatewayRequest request = mapper.readValue(entity.getContent(), ApiGatewayRequest.class);
                    ApiGatewayResponse response = handlerInstance.handleRequest(request, new CustomContext(requestId));
                    HttpPost post = new HttpPost(String.format("http://%s/2018-06-01/runtime/invocation/%s/response", runtimeApiEndpoint, requestId));
                    post.setEntity(new StringEntity(mapper.writeValueAsString(response)));
                    try (CloseableHttpClient httpPostClient = HttpClients.createDefault();
                            CloseableHttpResponse answer = httpClient.execute(post)) {
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        } catch (InstantiationException | IllegalAccessException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}

class CustomContext implements Context {

    private String requestId;

    public CustomContext(String requestId) {
        this.requestId = requestId;
    }

    @Override
    public String getAwsRequestId() {
        return requestId;
    }

    @Override
    public String getLogGroupName() {
        return System.getenv("AWS_LAMBDA_LOG_GROUP_NAME");
    }

    @Override
    public String getLogStreamName() {
        return System.getenv("AWS_LAMBDA_LOG_STREAM_NAME");
    }

    @Override
    public String getFunctionName() {
        return null;
    }

    @Override
    public String getFunctionVersion() {
        return System.getenv("AWS_LAMBDA_FUNCTION_VERSION");
    }

    @Override
    public String getInvokedFunctionArn() {
        return null;
    }

    @Override
    public CognitoIdentity getIdentity() {
        return null;
    }

    @Override
    public ClientContext getClientContext() {
        return null;
    }

    @Override
    public int getRemainingTimeInMillis() {
        return 0;
    }

    @Override
    public int getMemoryLimitInMB() {
        return 0;
    }

    @Override
    public LambdaLogger getLogger() {
        return null;
    }
}