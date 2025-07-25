export interface ToDirectory{
  url:string,
  name:string,
  isOver:boolean
}
export interface Data{
  NovelVolumeTitle:string,
  Title:title[]
}
export interface title{
  TitleName:string,
  TitleLink:string
}
export interface GetBookDirectoryData{
  status:boolean,
  data:Data[]
}