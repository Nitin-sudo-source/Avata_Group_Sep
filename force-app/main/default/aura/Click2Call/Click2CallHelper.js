({
       /*fetchProjects : function(component,event,helper) {
		 var action = component.get("c.getProjects");
            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var projects = response.getReturnValue();
                console.log("Fetched Projects:", projects); 
                component.set("v.project", projects);
                console.log("v.project after setting:", component.get("v.project"));
                
            } else {
                console.error("Failed to fetch Projects " + response.getError());
            }
        });
        // Enqueue the action to run
        $A.enqueueAction(action);
	}, */
    showToast : function(type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
	closeQuick : function(cmp,event) {
		  $A.get("e.force:closeQuickAction").fire();
	},
	//to fetch DID numbers`
    fetchdidnumbers:function(component,event,helper){
        var action = component.get("c.getTheObjectDetails");
         action.setParams({ 'recId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var projectsdid = response.getReturnValue();
                console.log("Fetched Projects DID's :", projectsdid); 
                component.set("v.project", projectsdid);
                console.log("v.project after setting:", component.get("v.project"));
                
            } else {
                console.error("Failed to fetch Projects DID numbers " + response.getError());
            }
        });
        // Enqueue the action to run
        $A.enqueueAction(action);
    },
})