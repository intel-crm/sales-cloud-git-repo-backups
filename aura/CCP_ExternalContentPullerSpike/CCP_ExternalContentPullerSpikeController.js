({
    onRender: function(cmp)  {
        try{
            var target = cmp.get('v.target');
            console.log('externalURL = '+ target);
            console.log('externalURL1 = '+ cmp.get('v.target1'));
            var frame = document.getElementById("externalAssetsIFrame");
            frame.src =  target;
            console.log('frame = '+ frame);  
        }catch(error){
            console.log(error);
        }
    }
})