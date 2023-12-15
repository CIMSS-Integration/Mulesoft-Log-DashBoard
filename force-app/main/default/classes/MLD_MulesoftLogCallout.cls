public class MLD_MulesoftLogCallout {
    
    @AuraEnabled
    public static Map<String,String> getMulesoftEnvData(){
        Map<String,String> envDataMap = new Map<String,String>();
        
        try{
            String envAPI = 'callout:Mulesoft_Logs/accounts/api/organizations/e53738af-de8e-479b-9edd-3d6d1a96876b/environments';
            HttpRequest getEnvRequest = new HttpRequest();
            getEnvRequest.setEndpoint(envAPI); 
            getEnvRequest.setMethod('GET');
            Http envHTTP = new Http();
            system.debug('Sending Request');
            HttpResponse envDataResponse = envHTTP.send(getEnvRequest);
            system.debug(envDataResponse);
            system.debug(envDataResponse.getBody());
            Type envType = Type.forName('MLD_MulesoftEnvResponse');
            MLD_MulesoftEnvResponse envResults = (MLD_MulesoftEnvResponse)JSON.deserialize(envDataResponse.getBody(), envType);
            system.debug(envResults.data);
            
            for(Integer i=0; i<envResults.data.size(); i++){
                envDataMap.put(envResults.data[i].name,envResults.data[i].id);
            }
            system.debug(envDataMap);
           
        } catch(Exception e) {
            system.debug('Error Occured!');
            system.debug('Class: MLD_MulesoftLogCallout');
            system.debug('Method: getMulesoftEnvData');
            system.debug('Line Number: '+e.getLineNumber());
            system.debug('Cause: '+e.getCause());
            system.debug('Message: '+e.getMessage());
        }
        
        return envDataMap;
        
    }
    
    @AuraEnabled
    public static List<String> getMulesoftAppData(String envId){
        List<String> appDomain = new List<String>();
        
        try{
            String appAPI = 'callout:Mulesoft_Logs/cloudhub/api/v2/applications';
            HttpRequest getAppRequest = new HttpRequest();
            getAppRequest.setHeader('x-anypnt-env-id', envId);
            getAppRequest.setEndpoint(appAPI); 
            getAppRequest.setMethod('GET');
            Http appHTTP = new Http();
            system.debug('Sending Request');
            HttpResponse appDataResponse = appHTTP.send(getAppRequest);
            system.debug(appDataResponse);
            system.debug(appDataResponse.getBody());
            List<Object> appResults = (List<Object>)JSON.deserializeUntyped(appDataResponse.getBody());
            system.debug(appResults);
            system.debug(appResults.isEmpty());
            
            if(!appResults.isEmpty()){
                for(Object obj: appResults){
                    Map<String,Object> app =  (Map<String,Object>)obj;
                    system.debug(app.get('domain'));
                    appDomain.add((String)app.get('domain'));
                }
                system.debug(appDomain);
            }
        } catch(Exception e) {
            system.debug('Error Occured!');
            system.debug('Class: MLD_MulesoftLogCallout');
            system.debug('Method: getMulesoftAppData');
            system.debug('Line Number: '+e.getLineNumber());
            system.debug('Cause: '+e.getCause());
            system.debug('Message: '+e.getMessage());
        }
        
        return appDomain;
    }
    
    public static void getMulesoftLogs(){
        
        // Callout to Get Mulesoft Organization Details
        /*String organizationIdAPI = 'callout:Mulesoft_Logs/accounts/api/me';
        system.debug(organizationIdAPI);
        HttpRequest getOrganizationData = new HttpRequest(); 
        getOrganizationData.setEndpoint(organizationIdAPI); 
        getOrganizationData.setMethod('GET');
        Http organizationHTTP = new Http();
        system.debug('Sending Request');
        HttpResponse organizationDataResponse = organizationHTTP.send(getOrganizationData);
        system.debug(organizationDataResponse);
        Map<String,Object> organizationData = (Map<String, Object>)JSON.deserializeUntyped(organizationDataResponse.getBody());
        system.debug(organizationData);
        system.debug(organizationData.get('user'));
        Map<String, Object> getUser = (Map<String, Object>)organizationData.get('user');
        system.debug(getUser.get('organization'));
        Map<String, Object> getOrganization = (Map<String, Object>)getUser.get('organization');
        system.debug(getOrganization.get('id'));*/	
        
        // Callout to Get Mulesoft Log Details
        String logAPI = 'callout:Mulesoft_Logs/cloudhub/api/v2/applications/deploy-practice/instances/65672743762a2176c076ae8c-0/logs';
        HttpRequest getLogRequest = new HttpRequest(); 
        getLogRequest.setHeader('x-anypnt-env-id','96c709f0-feb0-473b-bab1-1c03f04cf8a4');
        getLogRequest.setEndpoint(logAPI); 
        getLogRequest.setMethod('GET');
        Http logHTTP = new Http();
        system.debug('Sending Request');
        HttpResponse logDataResponse = logHTTP.send(getLogRequest);
        system.debug(logDataResponse);
        system.debug(logDataResponse.getBody());
        Type logType = Type.forName('MLD_MulesoftLogResponse');
        MLD_MulesoftLogResponse logResults =  (MLD_MulesoftLogResponse)JSON.deserialize(logDataResponse.getBody(), logType);
        System.debug('==========> deserialize() results = ' + logResults);
        System.debug(logResults.data);
        System.debug(logResults.data.size());
        //System.debug(logResults.logData[0]);
        System.debug(logResults.total);
        
        System.TimeZone myTz = UserInfo.getTimeZone();
        List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        for(Integer i=0; i<logResults.data.size(); i++){
            MLD_MulesoftLogResponse.logRecord log = logResults.data[i];
            
            Integration_Log__c intLog = new Integration_Log__c();
            intLog.Name = 'deploy-practice - ' + String.valueOf(log.timestamp);
            intlog.Instance_Id__c = log.instanceId;
            intLog.Logger_Name__c = log.loggerName;
            intLog.Thread_Name__c = log.threadName;
            intLog.Message__c = log.message;
            intLog.Priority__c = log.priority;
            intLog.Time_Stamp__c = DateTime.newInstance(log.timestamp + myTz.getOffset(DateTime.newInstance(log.timestamp)));
            
            intLogList.add(intLog);
        }
        
        if(!intLogList.isEmpty()){
            insert intLogList;
        }
        
        /*String restAPIURL = 'https://anypoint.mulesoft.com/accounts/login';
        system.debug(restAPIURL);
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setEndpoint(restAPIURL); 
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type','application/json');
		httpRequest.setHeader('User-Agent','Salesforce/1.0');
		String body = '{"username":"VishalDubey08", "password":"Vishal08"}';
        httpRequest.setBody(body);
        Http http = new Http();
        system.debug('Sending Request');
        HttpResponse httpResponse = http.send(httpRequest);
        system.debug(httpResponse);*/
    }

}


/*
 	public class MLD_MulesoftLogCallout {
    
    public static void getMulesoftLogs(){
        String restAPIURL = 'https://anypoint.mulesoft.com/accounts/login';
        system.debug(restAPIURL);
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setEndpoint(restAPIURL); 
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type','application/json');
		httpRequest.setHeader('User-Agent','Salesforce/1.0');
		String body = '{"username":"VishalDubey08", "password":"Vishal08"}';
        httpRequest.setBody(body);
        Http http = new Http();
        system.debug('Sending Request');
        HttpResponse httpResponse = http.send(httpRequest);
        system.debug(httpResponse);
    }

}
*/