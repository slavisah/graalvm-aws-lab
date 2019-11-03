package com.comsysto.lab.grlaws;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class Handler implements RequestHandler<ApiGatewayRequest, ApiGatewayResponse> {

    public ApiGatewayResponse handleRequest(final ApiGatewayRequest request, final Context context) {
        return ApiGatewayResponse.builder()
                .setStatusCode(200)
                .setObjectBody("hello")
                .build();
    }
}
