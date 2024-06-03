/**
 * @description       : HTTP Mock response generator. Used in test classes
 * @author            : luiz.brandao
 * @group             : 
 * @last modified on  : 03-20-2024
 * @last modified by  : luiz.brandao
**/
@isTest
public with sharing class MockHttpResponseGenerator implements HttpCalloutMock{
    private String mockBody;
    private Map<String, String> headers;
    private Integer statusCode;
    
    //TO-DO: Verificar se tem como fazer multicallout mock para essa interface

    /**
    * @description Constructor for the Mock Generator. Receives parameters according to the desired mock response
    * @author luiz.brandao | 03-20-2024 
    * @param mockBody - Body to be returned in the mock response
    * @param headers - Headers to be returned in the mock response
    * @param statusCode - HTTP Status Code to be returned in the mock response
    **/
    public MockHttpResponseGenerator(String mockBody, Map<String,String> headers, Integer statusCode) {
        this.mockBody = mockbody;
        this.statusCode = statusCode;
        //TO-DO: VERIFICAR SE É A MELHOR FORMA
        this.headers = headers;
    }

    /**
    * @description 
    * @author luiz.brandao | 03-20-2024 
    * @param req - Request object
    * @return HTTPResponse 
    **/
    public HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        
        if(headers != null){
            for(String headerKey : headers.keySet()){
                res.setHeader(headerKey, headers.get(headerKey));
            }
        }
        
        res.setBody(mockBody);
        res.setStatusCode(statusCode);

        return res;
    }
}