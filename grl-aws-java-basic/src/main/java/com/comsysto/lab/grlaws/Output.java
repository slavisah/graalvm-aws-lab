package com.comsysto.lab.grlaws;

public class Output {

    private String result;

    private String requestId;

    public String getResult() {
        return result;
    }

    public String getRequestId() {
        return requestId;
    }

    public Output setResult(String result) {
        this.result = result;
        return this;
    }

    public Output setRequestId(String requestId) {
        this.requestId = requestId;
        return this;
    }
}
