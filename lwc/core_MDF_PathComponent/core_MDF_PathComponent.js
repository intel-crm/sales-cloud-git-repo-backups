import { LightningElement ,api} from 'lwc';

export default class Core_MDF_PathComponent extends LightningElement {
    
    
    @api path;
    @api changePath(path){
        let targetId = path+'-217';
        let len = targetId.length;
        let mainTarId = targetId.charAt(4);
        let targatPrefix = targetId.substring(5, len);

        const lwcEvent= new CustomEvent('pathselection', {
            detail:{path:path} 
           });
          this.dispatchEvent(lwcEvent);
        
          var selectedPath = this.template.querySelector("[id=" +targetId+ "]");
        if(selectedPath){
            this.template.querySelector("[id=" +targetId+ "]").className='slds-is-active slds-path__item';
        }
            for(let i = 0; i < mainTarId; i++){
                let selectedPath = this.template.querySelector("[id=pat-" +i+ targatPrefix+"]");
                 
                if(selectedPath){
                    this.template.querySelector("[id=pat-" +i+ targatPrefix+"]").className='slds-is-complete slds-path__item';
                }
            }
            for(let i = mainTarId; i < 8; i++){
                if(i != mainTarId){
                    let selectedPath = this.template.querySelector("[id=pat-" +i+ targatPrefix+"]");
                    
                    if(selectedPath){
                        this.template.querySelector("[id=pat-" +i+targatPrefix+ "]").className='slds-is-incomplete slds-path__item';
                    }
                }
            }

        
    }



    pathHandler(event)
    {
        let targetId = event.currentTarget.id;
        let len = targetId.length;
        let mainTarId = targetId.charAt(4);
        let targatPrefix = targetId.substring(5, len);
        this.path = targetId.substring(0, 5);
        const lwcEvent= new CustomEvent('pathselection', {
            detail:{path:this.path} 
           });
          this.dispatchEvent(lwcEvent);
        var selectedPath = this.template.querySelector("[id=" +targetId+ "]");
        if(selectedPath){
            this.template.querySelector("[id=" +targetId+ "]").className='slds-is-active slds-path__item';
        }
            for(let i = 0; i < mainTarId; i++){
                let selectedPath = this.template.querySelector("[id=pat-" +i+ targatPrefix+"]");
                 
                if(selectedPath){
                    this.template.querySelector("[id=pat-" +i+ targatPrefix+"]").className='slds-is-complete slds-path__item';
                }
            }
            for(let i = mainTarId; i < 8; i++){
                if(i != mainTarId){
                    let selectedPath = this.template.querySelector("[id=pat-" +i+ targatPrefix+"]");
                    
                    if(selectedPath){
                        this.template.querySelector("[id=pat-" +i+targatPrefix+ "]").className='slds-is-incomplete slds-path__item';
                    }
                }
            }
    }
}