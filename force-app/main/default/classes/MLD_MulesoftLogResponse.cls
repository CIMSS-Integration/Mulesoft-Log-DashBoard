public class MLD_MulesoftLogResponse {

    // Mulesoft Logs JSON Response Wrapper
    public List<logRecord> data;
	public Integer total;

	public class logRecord {
		public String loggerName;
		public String threadName;
		public Long timestamp;
		public String message;
		public String priority;
		public String instanceId;
	}
    
    public static void test(){
        if(Test.isRunningTest()){
            system.debug('Test Running');
        }
    }
}