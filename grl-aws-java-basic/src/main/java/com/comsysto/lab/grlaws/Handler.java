package com.comsysto.lab.grlaws;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class Handler implements RequestHandler<Input, Output> {

    public Output handleRequest(final Input request, final Context context) {
        return new ProcessingService().process(request).setRequestId(context.getAwsRequestId());
    }
}
