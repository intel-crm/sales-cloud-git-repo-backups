
@page {
    size:portrait; 
   /* margin:10px;*/
        margin:25px 5px;    
    @top-center {
        content: element(header);
    }
    @bottom-center {
        content: element(footer);
    }
} 

.page:before {
    content: counter(page);
}
.totalPages:before {
    content: counter(pages);
}
div.header, div.footer {
    position: running(header);
    text-align:left;
    font-weight:bold; 
    font-size:14px;
   /* color:#87CEFA;*/
}
div.footer {
    position: running(footer);
    text-align:center;
    font-size:14px;
    color:#454545;
    display: flex;
    <!-- justify-content: space-between;
    padding: 0 20px;-->
    
}  

.pagenumber{
    text-align:right;
    font-weight:bold; 
    font-size:14px;
}

.row {
    width: 100%;
    margin-bottom: 10px;
    overflow-x: auto;
    max-width: 100%;
    
}

.cell2 {
    width:100%;
    overflow-x: auto;
    max-width: 100%;
    margin:10px 0px;
    border: 2px solid #1c52a3;  


}
.custom-table {
   table-layout: fixed;
    word-wrap: break-word;
    overflow-wrap: break-word;
    width: 100%;
    border-collapse: collapse;
    border: 1px solid #4a79c9; /* border blue */
}

.custom-table th {
    background-color: #4a79c9; /* blue header */
    color: white;
    padding: 5px;
    text-align: center;
}

.custom-table td {
    width:50%;
    padding: 5px;
    border: 1px solid #c6d4f2;
    text-align: right;
}

.custom-table2 {
    /*margin:5px;*/
    width: 100%;
    border-collapse: collapse;
    border: 1px solid #4a79c9; /* border blue */
}


.custom-table2  th {
    background-color: #4a79c9; /* blue header */
    color: white;
    padding: 5px;
    text-align: center;
    border: 1px solid white;
    width:auto
}

.custom-table2 td {
    /*width:auto;*/
    padding: 5px;
    border: 1px solid #c6d4f2;
    text-align: left;
}

.custom-table3 {
    /*margin:5px;*/
    width: 100%;
    border-collapse: collapse;
    border: 1px solid #4a79c9; /* border blue */
}


.custom-table3 th {
    background-color: #4a79c9; /* blue header */
    color: white;
    padding: 5px;
    text-align: center;
    border: 1px solid white;
    width:auto
}
.custom-table3 td {
    width:auto;
    padding: 5px;
    border: 1px solid #c6d4f2;
    text-align: left;
}


.bgcolor1 {
    background-color: #e8effc;
}

.bgcolor2 {
    background-color: #ffffff;
}

.table-header{
    text-align: center;
    background-color:#3a71c9;
    color:white;
    text-decoration: underline;
    
}

.title{
    text-align: center;
    text-decoration: underline;
    color:#3a71c9;

}