import { LightningElement, track, api } from 'lwc';
export default class PreviewGenericPublicVideo extends LightningElement {
     vid;
    renderedCallback(){
        this.vid = this.template.querySelector('video');
    }
    playVideo(){
        this.vid.play();

    }
}