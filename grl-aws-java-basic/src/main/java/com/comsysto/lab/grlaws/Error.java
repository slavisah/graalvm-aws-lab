package com.comsysto.lab.grlaws;

public class Error {
    private String errorType;
    private String errorMessage;

    public Error(String errorType, String errorMessage) {
        this.errorType = errorType;
        this.errorMessage = errorMessage;
    }

    public Error() {
    }

    public String getErrorType() {
        return errorType;
    }

    public Error setErrorType(String errorType) {
        this.errorType = errorType;
        return this;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public Error setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
        return this;
    }
}
