public class MLD_MulesoftInstResponse {

    // Mulesoft Instance JSON Response Wrapper
    public class InstancesData {
		public String instanceId;
		public String publicIPAddress;
		public String status;
		public String region;
	}

	public List<Data> data;
	public Integer total;

	public class Data {
		public String deploymentId;
		public String createTime;
		public String startTime;
		public String endTime;
		public List<InstancesData> instances;
	}
    
    public static void test(){
        if(Test.isRunningTest()){
            system.debug('Test Running');
        }
    }
}