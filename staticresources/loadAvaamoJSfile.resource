window.loadBot = function(){
	console.log('This is from bot function');
	var AvaamoChatBot=function(t){function o(t,o){var n=document.createElement("script");n.setAttribute("src",t),n.setAttribute("id","avm-web-channel"),n.onload=o,document.body.appendChild(n)}return this.options=t||{},this.load=function(t){o(this.options.url,function(){t&&"function"==typeof(t)&&t(window.Avaamo)})},this};
		var chatBox = new AvaamoChatBot({url: "https://c0.avaamo.com/web_channels/dd4a570c-3634-455d-b574-e864fb020401"});
			console.log('before function call');
		chatBox.load();
		console.log('after function call');
}