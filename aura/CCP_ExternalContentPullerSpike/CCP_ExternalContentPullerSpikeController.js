({
    onRender: function(component)  {        
        try{
            var target = component.get('v.target');
            console.log('externalURL = '+ target);
            console.log('externalURL1 = '+ component.get('v.target1'));
            var frame = document.getElementById("externalAssetsIFrame"); 
            //var frame = component.find("externalAssetsIFrame");           
            frame.src =  target;
            console.log('frame = '+ frame);  
           	frame.style.height = frame.contentWindow.parent.document.body.scrollHeight + 'px';
            console.log('frame.contentWindow.parent' +frame.contentWindow.parent);
           	console.log('frame.style.height' +frame.style.height);
        }catch(error){
            console.log(error);
        }
    }

})