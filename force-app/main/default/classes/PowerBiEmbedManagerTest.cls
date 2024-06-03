/**
 * @description       : 
 * @author            : Ewerton Bezerra
 * @group             : 
 * @last modified on  : 05-28-2024
 * @last modified by  : Ewerton Bezerra
**/

@isTest
private class PowerBiEmbedManagerTest {
    @isTest
    static void testGetPowerBiAccessToken() {
        // Create a test instance of the powerBiAuthSetting__mdt custom metadata type
        powerBiAuthSetting__mdt authSetting = new powerBiAuthSetting__mdt();
        authSetting = powerBiAuthSetting__mdt.getInstance('PowerBiApp');

        // Create a mock response for the HTTP callout
        String mockAccessToken = '{"access_token":"mock_access_token"}';        
        Integer statusCode = 200;

        // Set up the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockAccessToken, null, statusCode));
        
        // Call the getPowerBiAccessToken method and assert the expected access token
        Test.startTest();
        String accessToken = PowerBiEmbedManager.getPowerBiAccessToken();
        Test.stopTest();
        
        System.assertEquals('mock_access_token', accessToken);
    }

    @isTest
    static void testGetEmbeddingDataForReport() {
        // Create test data
        String workspaceId = 'test_workspace_id';
        String reportId = 'test_report_id';       
        DateTime expectedDateTime = DateTime.newInstanceGMT(2024, 5, 28, 12, 0, 0);

        // Create a mock response for the HTTP callouts
        String mockGetReportResponse = '{"id":"test_report_id", "reportType": "Test Type","name":"Test Report","embedUrl":"https://example.com/report","webUrl":"https://example.com/report","isFromPbix":"true","isOwnedByMe":"true","datasetId":"test_dataset_id"}';        
        Integer statusCodeGetReportResponse = 200;

        String mockGetEmbedTokenResponse = '{"token":"test_embed_token","tokenId":"123456","expiration":"2024-05-28T12:00:00.000Z"}';        
        Integer statusCodeMockGetEmbedTokenResponse = 200;

        // Set up the mock HTTP callouts        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockGetReportResponse, null, statusCodeGetReportResponse));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockGetEmbedTokenResponse, null, statusCodeMockGetEmbedTokenResponse));

        // Call the getEmbeddingDataForReport method and assert the expected results
        Test.startTest();
        PowerBiEmbedManager.PowerBiReportData reportData = PowerBiEmbedManager.getEmbeddingDataForReport(workspaceId, reportId);
        Test.stopTest();
        
        System.assertEquals(workspaceId, reportData.workspaceId);
        System.assertEquals(reportId, reportData.reportId);
        System.assertEquals(expectedDateTime, reportData.embedTokenExpires);
        System.assertEquals('test_embed_token', reportData.embedToken);
        System.assertEquals(null, reportData.error);
    }
}