export function exportCSV(headers, totalData, fileName){
    if(!totalData || !totalData.length){
        return null;
    }
    const jsonObject = JSON.stringify(totalData)
    var current = new Date();
    var dateTimeStamp = current.toLocaleDateString() +" "+ current.toLocaleTimeString();

    var newFileName = fileName + " " + dateTimeStamp

    const result = convertToCSV(jsonObject, headers)
    if(result === null) return
    const blob = new Blob([result])
    const exportFileName = newFileName ? newFileName+'.csv' : 'export.csv'

    const link = document.createElement("a")
    if(link.download !== undefined){
        const url = URL.createObjectURL(blob)
        link.setAttribute("href", url)
        link.setAttribute("download", exportFileName)
        link.style.visibility='hidden'
        document.body.appendChild(link) 
        link.click()
        document.body.removeChild(link)
    }
}

function convertToCSV(objArray, headers){
    const columnDelimiter = ','
    const lineDelimeter = '\r\n'
    const actualHeaderKeys = Object.keys(headers)
   
    const headerToShow = Object.values(headers)
    let str = ''
    str+=headerToShow.join(columnDelimiter)
    str+=lineDelimeter
    const data = typeof objArray !=='object' ? JSON.parse(objArray):objArray
    

    data.forEach(obj => {
        let line = ''
   
        actualHeaderKeys.forEach(key=>{
            if(line!=''){
                line+=columnDelimiter
            
            }
            if(obj[key] === undefined){
                obj[key] = '' 
            }
            let strIntem = obj[key]+''
            line+= strIntem ? strIntem.replace(/,/g, ' ; '):strIntem
        })
        str+=line+lineDelimeter
    })
    console.log('str',str)
    return str
}