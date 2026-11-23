import { LightningElement, api } from 'lwc';
import {  maximize } from 'lightningsnapin/minimized';
export default class Sales_BotLauncher extends LightningElement {
		@api elements;
		@api callChatbot;
		connectedCallback(){
				//console.log('DOM Ready State --> ' + document.readyState);
				//window.setTimeout(this.launchBot, 15000);
				//maximize();
				this.callChatbot=true;
				console.log('calling chatbot launchBot()');
		}

		launchBot(){
				console.log('inside launchBot()');
				if (document.readyState === "complete") { 
						console.log('inside if');
						//maximize();
						//this.elements = window.document.getElementsByClassName('flatButton');
						//console.log('Elements-->'+JSON.stringify(this.elements));				
				}  
		}

}