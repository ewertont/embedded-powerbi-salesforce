/**
 * @description       : 
 * @author            : Ewerton Bezerra
 * @group             : 
 * @last modified on  : 06-03-2024
 * @last modified by  : Ewerton Bezerra
**/

public with sharing class PowerBiEmbedManager {    
    public class ClientCredentialPostData {
        public String client_id;
        public String client_info;
        public string username;
        public string password;
        public String scope;
        public string grant_type;
        public String getPostData(){
          return 'client_id=' + this.client_id + 
                '&client_info=' + this.client_info +
                '&username=' + this.username +
                '&password=' + this.password +
                '&scope=' + this.scope +
                '&grant_type=' + grant_type;
        }
    }

    public class ClientCredentialResponse {
    	public String access_token;
        public String expires_in;
        public String ext_expires_in;
        public String token_type;
    }
    
    public class PowerBiReport    {
        public String id { get; set; } 
        public String reportType { get; set; } 
        public String name { get; set; } 
        public String webUrl { get; set; } 
        public String embedUrl { get; set; } 
        public boolean isFromPbix { get; set; } 
        public boolean isOwnedByMe { get; set; } 
        public String datasetId { get; set; } 
   }
    
    public class PowerBiEmbedToken    {
        public string token { get; set; } 
        public string tokenId { get; set; } 
        public DateTime expiration { get; set; } 
    }
 
    public class PowerBiReportData    {
    	@AuraEnabled
        public String workspaceId { get; set; } 
    	@AuraEnabled
        public String reportId { get; set; } 
    	@AuraEnabled
        public String name { get; set; } 
    	@AuraEnabled
        public String embedUrl { get; set; } 
    	@AuraEnabled
        public String embedToken { get; set; } 
    	@AuraEnabled
        public DateTime embedTokenExpires { get; set; } 
        @AuraEnabled
        public String error { get; set; } 
     }
    
    public static String getPowerBiAccessToken() {

        // get auth settings from Custom Metadata Type reconrd
        powerBiAuthSetting__mdt authSetting = powerBiAuthSetting__mdt.getInstance('PowerBiApp');
        string TenantId = authSetting.TenantId__c;    
        string ClientId = authSetting.ClientId__c;    
        string Username = authSetting.PowerBiUsername__c;  
        string Password = authSetting.PowerBiPassword__c;         

        // construct URL for client credentials flow
        String aadTokenEndpoint = 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';

        // prepare HTTP request 
        HttpRequest reqClientCredentialsFlow = new HttpRequest();
        reqClientCredentialsFlow.setMethod('POST');
        reqClientCredentialsFlow.setEndpoint(aadTokenEndpoint);        
        reqClientCredentialsFlow.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // compose data for POST body
        ClientCredentialPostData postData = new ClientCredentialPostData();
		postData.client_id = ClientId;
		postData.username = Username;
		postData.password = Password;
		postData.client_info = '1';
		postData.scope = 'https://analysis.windows.net/powerbi/api/.default';
		postData.grant_type = 'password';        
        String postBody = postData.getPostData();
        reqClientCredentialsFlow.setBody(postBody);

        // send HTTP POST to execute client credentials flow
        Http http = new Http();        
        HttpResponse response = http.send(reqClientCredentialsFlow);
 
        // extract and return app-only access token for service principal
        String responseJson = response.getBody();
        ClientCredentialResponse responseData = (ClientCredentialResponse)JSON.deserialize(responseJson, ClientCredentialResponse.class);
        String access_token = responseData.access_token;         
        return access_token;
    }
   
    @AuraEnabled(cacheable=true)
    public static PowerBiReportData getEmbeddingDataForReport(String WorkspaceId, String ReportId) {

        // get access token for Authorization header
        String access_token = getPowerBiAccessToken();        

        // Call to Power BI Service API to get report data for embedding        
        HttpRequest reqGetReport = new HttpRequest();
        reqGetReport.setMethod('GET');
        String urlGetReport = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId;
        reqGetReport.setEndpoint(urlGetReport);
        reqGetReport.setHeader('Authorization', 'Bearer ' + access_token);
        
        Http http = new Http();        
        HttpResponse response = http.send(reqGetReport);
        
        // check response for success
        if(response.getStatusCode()!=200){
            PowerBiReportData getReportError = new PowerBiReportData();
            getReportError.error = 'Get Report Error: ' + response.getStatus();
            return getReportError;            
        }            
    
        // extract Power BI report data from JSON response
        String responseJson = response.getBody();
        PowerBiReport powerBiReport = (PowerBiReport)JSON.deserialize(responseJson, PowerBiReport.class);      

	    // Call to Power BI Service API to get embed token for report        
        HttpRequest reqGetEmbedToken = new HttpRequest();
        reqGetEmbedToken.setMethod('POST');
        String urlGetEmbedToken = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        reqGetEmbedToken.setEndpoint(urlGetEmbedToken);
        reqGetEmbedToken.setHeader('Authorization', 'Bearer ' + access_token);    
        reqGetEmbedToken.setBody('{"accessLevel": "View", "datasetId": "datasetID"}');
    
        HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);

        // check response for success
        if(responseEmbedToken.getStatusCode()!=200){        
            PowerBiReportData getEmbedTokenError = new PowerBiReportData();
            getEmbedTokenError.error = 'Get Embed Token Error: ' + response.getStatus();
            return getEmbedTokenError;            
        }            

        // extract Power BI embed token and expiration
        PowerBiEmbedToken embedToken = (PowerBiEmbedToken)JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);
        
        // create custom remote-able object to return to caller in browser 
        PowerBiReportData powerBiReportData = new PowerBiReportData();        
        powerBiReportData.workspaceId = WorkspaceId;
        powerBiReportData.reportId = ReportId;
        powerBiReportData.name = powerBiReport.name;
        powerBiReportData.embedUrl = powerBiReport.embedUrl;
        powerBiReportData.embedToken = embedToken.token;
        powerBiReportData.embedTokenExpires = embedToken.expiration;
        
        return powerBiReportData;
    }
}