export interface  getChartsData{
  list:getChartsListData[],
  title:string
}
export interface getChartsListData{
  Booklink:string,
  Bookname:string,
  ImgSrc:string,
}
export interface getCharts{
  data:getChartsData[],
  status:boolean
}
