/*********************************************************************
Class Name: CustomTemplateController
Created By: MST - Robert Jaramillo 
Created On: 03-05-2020
Description: Controller for customTemplate Lightning Component 
*********************************************************************/
public class CustomTemplateController {
    
    @AuraEnabled
    public Boolean hasError;  //Used to verify if any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to store the exception message
    
    @AuraEnabled
    public String userMessage; //Used to store the custom error message
    
    @AuraEnabled
    public String templateBody;  //Used to store the template body
    
    @AuraEnabled
    public List<String> metadataList; //Used to store the template names
    
    @AuraEnabled
    public List<String> assignmentGrouptoptions;  //Used to store ROAE_Assignment_Group__c picklist values
    
    @AuraEnabled
    public List<String> taskTypeOptions;  //Used to store ROAE_Task_Type__c picklist values
    
    @AuraEnabled
    public Map<String,List<String>> dependentPicklistValues;  //Used to store task type picklist value dependencies
    
    @AuraEnabled
    public Map<String, String> queueMap;  //Used to store queues. Key = queue name, Value = queue ID
    
    @AuraEnabled
    public CustomTemplateController controller;
    
    @AuraEnabled //Get all template names from custom setting to display in a drop down 
    public static CustomTemplateController getMetadata(){
        CustomTemplateController controller = new CustomTemplateController();
        controller.metadataList = new List<String>();
        
        List<RO_OAE_Template__c > cd =  [SELECT id,Name,Body__c from RO_OAE_Template__c  ];
        //List<String> nameOFMeta = new List<String>();
        for(RO_OAE_Template__c  s: cd){
            controller.metadataList.add(s.Name);
        }
        return controller;
        //return nameOFMeta;
    }
    
    @AuraEnabled  //Gets template body. String input is name of template
    public static CustomTemplateController getTextMetadata(String text){
        
        CustomTemplateController controller = new CustomTemplateController();
        controller.templateBody = '';
            
        List<RO_OAE_Template__c > cd =  [SELECT id,Name,Body__c from RO_OAE_Template__c  where name =:text];
        if(cd.isEmpty()){
            return controller;
        }else{
            controller.templateBody = cd[0].Body__c;
           /* List<RO_OAE_Template__c > mapping =  [SELECT id,Name,SahilHanda__key__c,SahilHanda__value__c from RO_OAE_Template__c ];
            Map<String,String> mapOfMappings = new Map<String,String>();
            String fieldsToQuery ;
            List<String> fieldList = new List<String>();
            for(RO_OAE_Template__c  m: mapping){
                fieldsToQuery +=','+(m.SahilHanda__value__c);
                fieldList.add(m.SahilHanda__value__c);
                System.debug('m.SahilHanda__key__c+'+m.SahilHanda__key__c);
                System.debug('m.SahilHanda__value__c+'+m.SahilHanda__value__c);
                
                //body = body.replace(m.SahilHanda__key__c, m.SahilHanda__value__c);
                
            }
            fieldsToQuery = fieldsToQuery.replaceall('null,',' ');
            String query = 'SELECT'+fieldsToQuery +' FROM case where id = \'50036000001glmsAAA\' limit 1';
            System.debug('query'+query);
            List<sObject> sobjList = Database.query(query);
            
            for(String s : fieldList){
                mapOfMappings.put(s,String.valueOf((sobjList[0].get(s))));
                System.debug('body+'+(sobjList[0].get(s)));
            }
            for(SahilHanda__Template_MApping__c m: mapping){
                System.debug('m.SahilHanda__key__c+'+m.SahilHanda__key__c);
                System.debug('mapOfMappings+'+mapOfMappings);
                body = body.replace(m.SahilHanda__key__c, mapOfMappings.get(m.SahilHanda__value__c));
            }
            // */
            return controller;
            
        }
    } 
    
    @AuraEnabled //Create Task
    public static CustomTemplateController saveTask (String subject, String noteBody, Boolean rush, Date dueDate, String assignmentGroup, String taskType, String notes, String assignToId, String recordId){
        
        CustomTemplateController controller = new CustomTemplateController();
        controller.hasError = false;
        controller.errorMessage = '';
        controller.userMessage = '';
        
        try {
            String recordType = System.Label.Task_RO_OAE_RT;
            String taskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
            Task taskToBeCreated = new Task(Subject = subject,
                                            ROAE_Rush__c = rush,
                                            ActivityDate = dueDate,
                                            Priority = 'Normal',
                                            ROAE_Assignment_Group__c = assignmentGroup,
                                            ROAE_Task_Type__c = taskType,
                                            Notes_Comments__c = notes,
                                            OwnerId = assignToId,
                                            whatID = recordId,
                                            Status = 'Open',
                                            RecordTypeId = taskRecordType);
            
            System.debug('taskToBeCreated in create task = ' + taskToBeCreated);
            String userMessage = checkRequiredFields(taskToBeCreated);
            
            if(String.isNotBlank(userMessage) || String.isNotEmpty(userMessage)) {
                controller.userMessage = userMessage;
            }else {
                insert taskToBeCreated;
                List<Task> newTask = [SELECT Id FROM Task WHERE Id =: taskToBeCreated.Id];
                saveNotes(subject, noteBody, Id.valueOf(newTask[0].Id));
            }
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception:'+ e.getMessage();
            system.debug('Exception'+ e.getMessage());
        }
        return controller;
    } 
    
    @AuraEnabled //Create Note
    public static CustomTemplateController saveNotes (String noteTitle, String noteBody, String recordId){
        CustomTemplateController controller = new CustomTemplateController();
        controller.hasError = false;
        controller.errorMessage = '';
        controller.userMessage = '';
        
        System.debug('Notebody = ' + notebody);
        
        if(noteBody=='' || noteBody==null){
            controller.userMessage = 'Please enter text to template.';
        }else {
            try{
                ContentVersion cv =new ContentVersion();
                cv.Title = noteTitle;
                system.debug('noteBody'+Blob.valueOf(noteBody));
                cv.VersionData = Blob.valueOf(noteBody);
                cv.FirstPublishLocationId = recordId;
                cv.PathOnClient = cv.Title+'.snote';
                insert cv;
                
            } catch(Exception ex){
                controller.hasError = true;
                controller.errorMessage = 'Exception:'+ ex.getMessage();
                system.debug('Exception'+ ex.getMessage());
            }
        }
        return controller;
    }
    
    @AuraEnabled //Get ROAE_Assignment_Group__c, ROAE_Task_Type__c picklist values, and Task queues
    public static CustomTemplateController getPicklistValues(){
        CustomTemplateController controller = new CustomTemplateController();
        controller.assignmentGrouptoptions = new List<String>();
        controller.taskTypeOptions = new List<String>();
        controller.queueMap = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Task.ROAE_Assignment_Group__c.getDescribe();
        List<Schema.PicklistEntry> assignmentGroupPicklistValues = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry value : assignmentGroupPicklistValues){
            controller.assignmentGrouptoptions.add(value.getValue());
        }
        
        Schema.DescribeFieldResult taskTypeFieldResult = Task.ROAE_Task_Type__c.getDescribe();
        List<Schema.PicklistEntry> taskTypePicklistValues = taskTypeFieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry value : taskTypePicklistValues){
            controller.taskTypeOptions.add(value.getValue());
        }
        
        //Add dependent values to a Map
        controller.dependentPicklistValues = getPicklistDependencies(assignmentGroupPicklistValues, taskTypePicklistValues);
        
        //Get all Task Queues
        controller.queueMap = getTaskQueues();
        
        return controller;
    }
    
    //Adding dependent picklist values to a Map. Key is the controlling field and the key is a list of all dependent values.
    private static Map<String,List<String>> getPicklistDependencies(List<Schema.PicklistEntry> assignmentGroupPicklistValues, List<Schema.PicklistEntry> taskTypePicklistValues) {
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        for (Schema.PicklistEntry entry : taskTypePicklistValues) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (assignmentGroupPicklistValues != null ? assignmentGroupPicklistValues.size() : 2); index++) {
                    Object controlValue =
                        (assignmentGroupPicklistValues == null
                         ?   (Object) (index == 1)
                         :   (Object) (assignmentGroupPicklistValues[index].isActive() ? assignmentGroupPicklistValues[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        System.debug('dependentPicklistValues = ' + dependentPicklistValues);
        
        return dependentPicklistValues;
    }
    
    //Get all Task queues to display in a drop down
    private static Map<String, String> getTaskQueues() {
        Map<String, String> queueMap = new Map<String, String>();
        for(QueueSobject queue : [SELECT QueueId, Queue.Name FROM QueueSobject WHERE SobjectType = 'Task']) {
            queueMap.put(queue.Queue.Name, queue.QueueId);
        }
        System.debug('queueMap = ' + queueMap);
        return queueMap;
    }
    
    //Checks if required fields are populated. Required fields are set in custom metadata
    private static String checkRequiredFields(Task taskRecord){
        System.debug('taskToBeCreated in checkRequiredFields = ' + taskRecord);
        String userMessage = '';
        DescribeSObjectResult describe = SObjectType.Task;
        Map<String, SObjectField> allFields = describe.fields.getMap(); 
        Set<String> requiredFieldsSet = new Set<String>();
        Map<String, Required_Fields_on_Task__mdt> accRequiredFieldMap = new Map<String, Required_Fields_on_Task__mdt>();
        
        
        //Get required fields from the custom meta data
        for (Required_Fields_on_Task__mdt currentSetting : [SELECT Label, FieldSet__c FROM Required_Fields_on_Task__mdt LIMIT 1]) {
            if(!String.isBlank(currentSetting.FieldSet__c) && currentSetting.FieldSet__c.split(';') != null){
                for(String fieldName : currentSetting.FieldSet__c.split(';')){
                    requiredFieldsSet.add(fieldName);
                }
            }
        }
        
        //Add field label to the custom error message if the required field is not populated
        for(String fieldName : requiredFieldsSet) {
            if(String.isBlank(String.valueOf(taskRecord.get(fieldName)))) {
                DescribeFieldResult nameDescribe = allFields.get(fieldName).getDescribe();
                if(String.isBlank(userMessage)) {
                    userMessage += 'These required fields must be completed: ' + nameDescribe.getLabel();
                } else {
                    userMessage += +', '+nameDescribe.getLabel();
                }
            }
        }
        return userMessage;
    }
}