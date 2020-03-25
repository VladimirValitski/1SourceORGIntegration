/**
 * Created by vvalitsky on 10/3/2019.
 */

public class CalloutHandler {
    private static final String TEMPLATE_BODY =
            'grant_type=password&client_id={0}&client_secret={1}&username={2}&password={3}';

    public static Org1Data__mdt orgData {
        get {
            if (orgData == null) {
                orgData = [
                        SELECT clientId__c, clientSecret__c, endPointAuth__c,
                                endPointProducts__c, password__c, userName__c
                        FROM Org1Data__mdt
                        WHERE DeveloperName = 'Data'
                ][0];
            }
            return orgData;
        }
        private set;
    }

    @Future(Callout=true)
    public static void syncDestination(String httpMethod, String productListJSON) {
        List<Id> failedIds = new List<Id>();
        String accessToken = getAccessToken();
        if (String.isNotBlank(accessToken)) {
            failedIds = callDestination(httpMethod, accessToken, productListJSON);
        }
        if (!failedIds.isEmpty()) {
            ErrorUpdateDataMailer.sendReport(failedIds);
        }
    }

    private static List<String> callDestination(String httpMethod, String accessToken, String body) {
        List<String> failedIds = new List<String>();
        String endPointProd = orgData.endPointProducts__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setEndpoint(endPointProd);
        request.setMethod(httpMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody(body);
        try {
            response = http.send(request);
        } catch (System.CalloutException e) {
            // do smth
        }
        if (response.getStatusCode() == 202) {
            System.debug(response.getBody());
            failedIds = (List<String>)
                    JSON.deserializeStrict(response.getBody(), List<String>.class);
        }
        return failedIds;
    }

    private static String getAccessToken() {
        String accessToken = '';
        String endPoint = orgData.endPointAuth__c;
        List<String> bodyVariables = new List<String>{
                orgData.clientId__c,
                orgData.clientSecret__c,
                orgData.userName__c,
                orgData.password__c
        };
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(String.format(TEMPLATE_BODY, bodyVariables));
        request.setEndpoint(endPoint);
        try {
            response = http.send(request);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            accessToken = (String) responseMap.get('access_token');
        } catch (System.CalloutException e) {
            // do smth
        }
        return accessToken;
    }

}
