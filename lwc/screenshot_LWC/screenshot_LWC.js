import { LightningElement, track } from 'lwc';
import HTML2CANVAS from '@salesforce/resourceUrl/html2canvas';
import { loadScript } from 'lightning/platformResourceLoader';

export default class Screenshot_LWC extends LightningElement {

    @track imgsrc;

connectedCallback() {
	loadScript(this, HTML2CANVAS).then(() => {
		console.log('html2canvas loaded');
	});
}

imgsrc = '';

    printDiv() {
        console.log('Inside printDiv');
        this.imgsrc = '';
        const screenshot = this.template.querySelector('.print-preview-div');
        console.log('Inside printDiv screenshot'+screenshot);
        html2canvas(this.template.querySelector('.print-preview-div'),{ 
            scale: "5",
            onrendered: (canvas)=> {
                //show image
                var myCanvas = this.template.querySelector('.my_canvas_id');
                console.log('Inside printDiv myCanvas'+myCanvas);
                var ctx = myCanvas.getContext('2d');
                ctx.webkitImageSmoothingEnabled = false;
                ctx.mozImageSmoothingEnabled = false;
                ctx.imageSmoothingEnabled = false;
                console.log('Inside printDiv ctx'+ctx);
                var img = new Image;
                img.onload = function(){
                    ctx.drawImage(img,0,0,270,350); // Or at whatever offset you like
                };
                console.log('img >> ', canvas.toDataURL());
                img.src = canvas.toDataURL();
                this.imgsrc = img.src;
                console.log('Inside on rendered'+this.imgsrc)
            }
        });
         console.log('Inside printDiv after html2canvas'+this.imgsrc);
    }

}