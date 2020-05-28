({
	doInit : function(component, event, helper) {
        helper.getAutoTaskList(component, event);
    },
    
	handleRunAutoTask : function(component, event, helper) {
        helper.runAutoTask(component, event);
	},
})