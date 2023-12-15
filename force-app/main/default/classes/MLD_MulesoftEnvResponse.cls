public class MLD_MulesoftEnvResponse {
    
    // Mulesoft Environment JSON Response Wrapper
    public List<Data> data;
    public Integer total;
    
    public class Data {
        public String id;
        public String name;
        public String organizationId;
        public Boolean isProduction;
        public String type;
        public String clientId;
        public Object arcNamespace;
    }
    
    public static void test(){
        if(Test.isRunningTest()){
            system.debug('Test Running');
        }
    }
}