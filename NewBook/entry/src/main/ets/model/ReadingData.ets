export interface ToRouterData{
  BookName:String,
  title:String,
  NovelVolume:String,
  Link:string,
  isOver:boolean
}

export interface GetReadingData{
  status: boolean;
  content: PageInformation;
  roust:RouteData[]
}
export interface PageInformation{
  content:string,
  NovelVolumes:string,
  title:string
}
export interface RouteData{
  previous:roust,
  next:roust
}

export interface roust{
  text:string,
  link:string
}