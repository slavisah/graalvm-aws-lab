package com.comsysto.lab.grlaws;

import static com.comsysto.lab.grlaws.CustomRuntimeApi.LAMBDA_RUNTIME_AWS_REQUEST_ID;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.LAMBDA_RUNTIME_CLIENT_CONTEXT;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.LAMBDA_RUNTIME_COGNITO_IDENTITY;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.LAMBDA_RUNTIME_DEADLINE_MS;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.LAMBDA_RUNTIME_INVOKED_FUNCTION_ARN;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.functionMemorySize;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.functionName;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.functionVersion;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.logGroupName;
import static com.comsysto.lab.grlaws.CustomRuntimeApi.logStreamName;

import java.io.IOException;
import java.net.HttpURLConnection;

import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.LambdaRuntime;
import com.fasterxml.jackson.databind.ObjectReader;

public class CustomRuntimeContext implements Context {

    private String awsRequestId;
    private String logGroupName;
    private String logStreamName;
    private String functionName;
    private String functionVersion;
    private String invokedFunctionArn;
    private CognitoIdentity cognitoIdentity;
    private ClientContext clientContext;
    private long runtimeDeadlineMs = 0;
    private int memoryLimitInMB;
    private LambdaLogger logger;

    public CustomRuntimeContext(HttpURLConnection request, ObjectReader cognitoReader, ObjectReader clientCtxReader)
            throws IOException {
        awsRequestId = request.getHeaderField(LAMBDA_RUNTIME_AWS_REQUEST_ID);
        logGroupName = logGroupName();
        logStreamName = logStreamName();
        functionName = functionName();
        functionVersion = functionVersion();
        invokedFunctionArn = request.getHeaderField(LAMBDA_RUNTIME_INVOKED_FUNCTION_ARN);

        String cognitoIdentityHeader = request.getHeaderField(LAMBDA_RUNTIME_COGNITO_IDENTITY);
        if (cognitoIdentityHeader != null) {
            cognitoIdentity = cognitoReader.readValue(cognitoIdentityHeader);
        }

        String clientContextHeader = request.getHeaderField(LAMBDA_RUNTIME_CLIENT_CONTEXT);
        if (clientContextHeader != null) {
            clientContext = clientCtxReader.readValue(clientContextHeader);
        }

        String functionMemorySize = functionMemorySize();
        memoryLimitInMB = functionMemorySize != null ? Integer.valueOf(functionMemorySize) : 0;

        String runtimeDeadline = request.getHeaderField(LAMBDA_RUNTIME_DEADLINE_MS);
        if (runtimeDeadline != null) {
            runtimeDeadlineMs = Long.valueOf(runtimeDeadline);
        }
        logger = LambdaRuntime.getLogger();
    }

    @Override
    public String getAwsRequestId() {
        return awsRequestId;
    }

    @Override
    public String getLogGroupName() {
        return logGroupName;
    }

    @Override
    public String getLogStreamName() {
        return logStreamName;
    }

    @Override
    public String getFunctionName() {
        return functionName;
    }

    @Override
    public String getFunctionVersion() {
        return functionVersion;
    }

    @Override
    public String getInvokedFunctionArn() {
        return invokedFunctionArn;
    }

    @Override
    public CognitoIdentity getIdentity() {
        return cognitoIdentity;
    }

    @Override
    public ClientContext getClientContext() {
        return clientContext;
    }

    @Override
    public int getRemainingTimeInMillis() {
        return (int) (runtimeDeadlineMs - System.currentTimeMillis());
    }

    @Override
    public int getMemoryLimitInMB() {
        return memoryLimitInMB;
    }

    @Override
    public LambdaLogger getLogger() {
        return logger;
    }
}
