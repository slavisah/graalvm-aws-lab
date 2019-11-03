package com.comsysto.lab.grlaws;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.isA;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

class HandlerTest {

    Context context;
    LambdaLogger lambdaLogger;

    @BeforeEach
    void init() {
        context = mock(Context.class);
        lambdaLogger = mock(LambdaLogger.class);
    }

    @Test
    @DisplayName("handleRequest() with input string and mocked context")
    void handleRequest_InputAndMockedContext_ReturnStringWhichContainsInput() {
        Handler handler = new Handler();
        when(context.getLogger()).thenReturn(lambdaLogger);
        doNothing().when(lambdaLogger).log(isA(String.class));
        assertEquals("\"hello\"", handler.handleRequest(new ApiGatewayRequest(), context).getBody());

    }
}