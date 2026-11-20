({
    groupTags : function(component, helper) {
        console.log('group tags');
        var tags = component.get('v.tags');
        if (tags.length){
            var tagGroups = [
                {
                    id:'symbol',
                    label: 'Ω',
                    regex: /^[^a-z0-9].?/i, 
                    tags:[]
                },{
                    id:'Dabcd',
                    label: '#A-D',
                    regex: /^[abcd\d].?/i,
                    tags:[]
                },{
                    id:'efghi',
                    label: 'E-I',
                    regex: /^[efghi].?/i,
                    tags:[]
                },{
                    id:'jklmn',
                    label: 'J-N',
                    regex: /^[jklmn].?/i,
                    tags:[]
                },{
                    id:'opqrs',
                    label: 'O-S',
                    regex: /^[opqrs].?/i,
                    tags:[]
                },{
                    id:'tuvwx',
                    label: 'T-X',
                    regex: /^[tuvwx].?/i,
                    tags:[]
                }	,{
                    id:'yz',
                    label: 'YZ',
                    regex: /^[yz].?/i,
                    tags:[]
                }];
            tags.forEach(function(item){
                for (var i = 0, i_l = tagGroups.length; i < i_l; i++) {
                    if (tagGroups[i].regex.test(item.label)){
                        tagGroups[i].tags.push(item);
                        break;
                    }
                }
            });
            component.set('v.tagGrouping', tagGroups);
        }
    }
})