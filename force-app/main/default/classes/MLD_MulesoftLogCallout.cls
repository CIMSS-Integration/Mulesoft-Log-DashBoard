public class MLD_MulesoftLogCallout {
    
    @AuraEnabled
    public static Map<String,String> getMulesoftEnvData(){
        Map<String,String> envDataMap = new Map<String,String>();
        
        try{
            String envAPI = 'callout:Mulesoft_Logs/accounts/api/organizations/77499635-54f6-4772-ab84-3eb0295c07fa/environments';
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
    
    @AuraEnabled
    public static List<Integration_Log__c> getMulesoftLogs(String orgName, String envId, String envName, String appName, DateTime endDate, DateTime startDate, String logStatus){
        List<Integration_Log__c> updatedLogList = new List<Integration_Log__c>();
        
        try{
            system.debug('orgName: '+ orgName);
            system.debug('envId: '+ envId);
            system.debug('appName: '+ appName);
            system.debug('endDate: '+ endDate);
            system.debug('startDate: '+ startDate);
            //system.debug('logStatus: '+ logStatus);
            
            endDate = endDate.addDays(1);
            
            List<String> existingLogName = new List<String>();
            List<Integration_Log__c> existingLogList = [SELECT Name FROM Integration_Log__c];
            for(Integration_Log__c iLog: existingLogList){
                existingLogName.add(iLog.Name);
            }
            
            String instAPI = 'callout:Mulesoft_Logs/cloudhub/api/v2/applications/'+ appName +'/deployments';
            HttpRequest getInstRequest = new HttpRequest(); 
            getInstRequest.setHeader('x-anypnt-env-id', envId);
            getInstRequest.setEndpoint(instAPI); 
            getInstRequest.setMethod('GET');        
            Http instHTTP = new Http();
            system.debug('Sending Request');
            HttpResponse instDataResponse = instHTTP.send(getInstRequest);
            system.debug(instDataResponse);
            system.debug(instDataResponse.getBody());
            Type instType = Type.forName('MLD_MulesoftInstResponse');
            MLD_MulesoftInstResponse instResults =  (MLD_MulesoftInstResponse)JSON.deserialize(instDataResponse.getBody(), instType);
            System.debug('==========> deserialize() results = ' + instResults);
            System.debug(instResults.data);
            System.debug(instResults.data.size());
            
            String instId = '';
            for(Integer i=instResults.data.size()-1; i>=0; i--){
                List<MLD_MulesoftInstResponse.InstancesData> inst = instResults.data[i].instances;
                if(inst[0].status == 'STARTED'){
                    instId = inst[0].instanceId;
                    break;
                }
            }
            
            
            // Callout to Get Mulesoft Log Details
            String logAPI = 'callout:Mulesoft_Logs/cloudhub/api/v2/applications/'+ appName +'/instances/'+ instId +'/logs';
            HttpRequest getLogRequest = new HttpRequest(); 
            getLogRequest.setHeader('x-anypnt-env-id',envId);
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
                String intLogName = appName + ' - ' + String.valueOf(log.timestamp);
                
                if(!existingLogName.contains(intLogName)){
                    Integration_Log__c intLog = new Integration_Log__c();
                    intLog.Name = appName + ' - ' + String.valueOf(log.timestamp);
                    intlog.Instance_Id__c = log.instanceId;
                    intLog.Logger_Name__c = log.loggerName;
                    intLog.Thread_Name__c = log.threadName;
                    intLog.Message__c = log.message;
                    intLog.Log_Level__c = log.priority;
                    intLog.Time_Stamp__c = DateTime.newInstance(log.timestamp + myTz.getOffset(DateTime.newInstance(log.timestamp)));
                    intLog.Organization_Name__c = orgName;
                    intLog.Environment_Id__c = envId;
                    intLog.Environment_Name__c = envName;
                    intLog.Application_Name__c = appName;
                    //intLog.Log_Status__c = logStatus;
                    system.debug(intLog);
                    intLogList.add(intLog);
                }
            }
            
            if(!intLogList.isEmpty()){
                insert intLogList;
            }
            
            appName = appName + '%';
            String intLogQuery = 'SELECT Id, Name, Logger_Name__c, Time_Stamp__c, Log_Level__c, Message__C FROM Integration_Log__c WHERE Name LIKE :appName AND Environment_Id__c =:envId AND Time_Stamp__c >=:startDate AND Time_Stamp__c <=:endDate';
            if(logStatus == 'Success'){
                intLogQuery = intLogQuery + ' AND Log_Level__c!=\'ERROR\'';
            }
            else if(logStatus == 'Error'){
                intLogQuery = intLogQuery + ' AND Log_Level__c=\'ERROR\'';
            }
            
            intLogQuery = intLogQuery + ' ORDER BY CreatedDate DESC';
            updatedLogList = Database.query(intLogQuery);
            system.debug(updatedLogList);
        
            
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
            
        } catch(Exception e) {
            system.debug('Error Occured!');
            system.debug('Class: MLD_MulesoftLogCallout');
            system.debug('Method: getMulesoftLogs');
            system.debug('Line Number: '+e.getLineNumber());
            system.debug('Cause: '+e.getCause());
            system.debug('Message: '+e.getMessage());
        }
        
        return updatedLogList;	
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