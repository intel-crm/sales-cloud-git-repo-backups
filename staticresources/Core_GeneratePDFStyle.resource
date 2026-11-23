@page {
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
    justify-content: space-between;
    padding: 0 20px;
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
    border: 1px solid black;"
}

/* Table styling */
table {
    width: 100%;
    border-collapse: collapse;
    border: 1px solid black;
    page-break-inside: auto;
    page-break-after: auto;
}

table th, table td {
    padding: 8px;
    text-align: left;
    border: 1px solid black;
}

/* Handle large tables properly across pages */
table {
    page-break-inside: auto;
}
.img {
    width: auto;
    height: auto;
}