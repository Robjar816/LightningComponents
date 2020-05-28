({
    nextNavigation : function(component, event) {
        var radioButton1 = component.get("v.radioButton1");
        console.log("radioButton1 = " + radioButton1);
        
        var radioButton2 = component.get("v.radioButton2");
        console.log("radioButton2 = " + radioButton2);
        
        var radioButton3 = component.get("v.radioButton3");
        console.log("radioButton3 = " + radioButton3);
        
        if(radioButton1 == true) {
            component.set("v.showChooseRecordType", false);
            component.set("v.showUpdateFieldAction", true);
            component.set("v.showSendEmailAction", false);
            component.set("v.showSendSurveyAction", false);
        }else if(radioButton2 == true) {
            component.set("v.showChooseRecordType", false);
            component.set("v.showUpdateFieldAction", false);
            component.set("v.showSendEmailAction", true);
            component.set("v.showSendSurveyAction", false);
        }else if(radioButton3 == true) {
            component.set("v.showChooseRecordType", false);
            component.set("v.showUpdateFieldAction", false);
            component.set("v.showSendEmailAction", false);
            component.set("v.showSendSurveyAction", true);
        }
    },
    
    newRadioButtonSelected : function(component, event) {
        var buttonSelected = event.getSource().get("v.label");
        console.log("buttonSelected = " + buttonSelected);
        
        if(buttonSelected == "Update Field Action") {
            component.set("v.radioButton1", true);
            component.set("v.radioButton2", false);
            component.set("v.radioButton3", false);
        }else if(buttonSelected == "Send Email Action"){
            component.set("v.radioButton1", false);
            component.set("v.radioButton2", true);
            component.set("v.radioButton3", false);
        }else if(buttonSelected == "Send Survey Action"){
            component.set("v.radioButton1", false);
            component.set("v.radioButton2", false);
            component.set("v.radioButton3", true);
        }
        
        var updateFieldRT = component.get("v.radioButton1");
        console.log("updateFieldRT = " + updateFieldRT);
        
        var sendEmailRT = component.get("v.radioButton2");
        console.log("sendEmailRT = " + sendEmailRT);
        
        var sendSurveyRT = component.get("v.radioButton3");
        console.log("sendSurveyRT = " + sendSurveyRT);
    },
})