({
	doInit : function(component, event, helper) {
		helper.loadMessagingData(component).then($A.getCallback(function(responseMessage) {
			component.set('v.messages', responseMessage);
			window.setTimeout(function(){
				component.set('v.loading', false);
			}, 20);
			
			helper.scrollEnd(component);
		}));

		component.set('v.onSendClick', function(){
			$A.enqueueAction(component.get('c.handleMessageSend'));
		});
		/*window.setTimeout(function(){
			var chatComponent = component.find('slds-chat').getElement();
            console.log('slds-chat',component.find('slds-chat'));
			// debounce the scroll
			chatComponent.onscroll= function(e){
				var t = component.get('v._debounceSearchTimer');
				window.clearTimeout(t);
				t = window.setTimeout($A.getCallback(function() {
					$A.enqueueAction(component.get('c.handleScroll'));
				}), 250);
				component.set('v._debounceSearchTimer', t);
			}
		})
		*/
		//Assign User Id
		component.set("v.userID",$A.get("$SObjectType.CurrentUser.Id"));
        
        //Get UserName
        helper.getCurrentUserName(component).then($A.getCallback(function(responseMessage) {
           component.set("v.author",responseMessage); 
        }));
       
        
   },
   handleShow: function(component, event, helper) {
		helper.scrollEnd(component);
	},
	handleKeyDown: function(component, event, helper) {
		if (event.which == '13') {
			// enter key
			$A.enqueueAction(component.get('c.handleMessageSend'));
		} else {
			var empty = event.target.value ? false: true;
			component.set('v.messageEmpty', empty);
		}

	},
	handleScrollUp: function(component, event, helper) {
		helper.scrollPageUp(component, helper);

	},
    handleScroll: function(component, event, helper){
		var chatComponent = event.currentTarget;
		var t = component.get('v._debounceSearchTimer');
		window.clearTimeout(t);
		t = window.setTimeout($A.getCallback(function() {
			if (component.isValid()){
				component.set('v.scrollUp', chatComponent.scrollTop !== 0);
			}
		}), 250);
		component.set('v._debounceSearchTimer', t);
	},
    handleToggleOpen: function(component, event, helper){
		var isOpen = !component.get('v.mobileToggleChat');
		component.set('v.mobileToggleChat', isOpen);

		if (isOpen && component.get('v.mobileFirstToggle')) {
			helper.scrollEnd(component);
			component.set('v.mobileFirstToggle', false);
		}
	},


	handleMessageSend: function(component, event, helper) {
		var messages = component.get('v.messages');
		var inputField = component.find('usermessage').getElement();
		var outboundMessage = inputField.value;
		if (outboundMessage != '') {
			var message = { 
				author: component.get("v.author"),//'You @ intel',
				userID: component.get('v.userID'),
				timestamp: new Date().toISOString(),
				message: outboundMessage,
				type: 'message',
				direction: 'outbound'
			};
			// Post the message to server
			helper.postMessage(component, message).then($A.getCallback(function(responseMessage) {
				if (responseMessage) {
					messages.push(message)
					component.set('v.messages', messages);
					component.set('v.messageEmpty', true);
					
					inputField.value = '';
					// scroll down

					helper.scrollEnd(component);
				}
			}));
		}
	}

	
})