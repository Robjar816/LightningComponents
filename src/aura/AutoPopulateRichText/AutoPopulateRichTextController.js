({
	doInit : function(component, event, helper) {
		helper.getTemplates(component, event);
	},
    
    handleChange : function(component, event, helper) {
        helper.setTemplateContent(component, event);
    },
    
    handleSave : function(component, event, helper) {
        helper.saveNote(component, event);
    }
})