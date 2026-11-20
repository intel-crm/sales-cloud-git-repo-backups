export function getAccessToken() {

     //xxd645a3c4-d795-40ee-b989-90b6a5a3a515 //rajendra token xx22f240b9-9ff6-4b42-93ec-ec08f4765f6c

    var myHeaders = new Headers();
    myHeaders.append("Authorization", "Bearer xxd645a3c4-d795-40ee-b989-90b6a5a3a515");
    myHeaders.append("Content-Type", "application/json");

    var raw = JSON.stringify({  
        "pipeline": "IPSSBS",
        "searchHub": "IPSSBS",
        "validFor": 3600000,
        "userIds": [
            {
                "provider": "Email Security Provider",
                "name": "anonymous",
                "intel": {}
            }
        ]
    });

    var requestOptions = {
        method: 'POST',
        headers: myHeaders,
        body: raw,
        redirect: 'follow'
    };

    fetch("https://platform.cloud.coveo.com/rest/search/v2/token?organizationId=intelcorporationnonproduction2ybdyblf7", requestOptions)
        .then(response => response.text())
        .then(result => console.log(result))
        .catch(error => console.log('error', error));

}