@page {
    margin:35px 25px;
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
    color:#87CEFA;
}
div.footer {
    position: running(footer);
    text-align:center;
    font-size:14px;
    color:#454545;
    display: flex;
    
}  

.pagenumber{
    text-align:right;
    font-weight:bold; 
    font-size:14px;
}

.label{
    text-align: center;
    border: 1px solid black;
}

.value{
    text-align: left;
    border: 1px solid black;
}

/* Handle large tables properly across pages*/
.no-break {
    page-break-inside: avoid;
}

/*tr {
    page-break-inside: avoid;
}*/

table {
    -fs-table-paginate: paginate; /* Enables automatic pagination for the table */
    border-collapse: collapse;  /*Merges adjacent borders into a single border */
    border: 1px solid black;
    width:100%;
    
}

td, th {
    border: 1px solid black;      /* Apply consistent borders to cells */
    word-wrap: break-word;        /* Helps long words break to the next line */
}

caption {
    color:#0176d3;
    font-style: italic;
    text-align:left;
    margin-top:20px;
    margin-bottom:5px;
}

.displayasblockele {
    display: block;
}

td.merge {
    border-top: none;
    border-bottom: none;
}
td.merge.first {
    border-top: 1px solid #000;
}
td.merge.last {
    border-bottom: 1px solid #000;
}
