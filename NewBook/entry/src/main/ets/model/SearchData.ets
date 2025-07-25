export class SearchData{
  BookName:string;//书名
  BookLink:string;//书面
  BookAuther:string
  BookImg:string//id，地址
  // 1 想看
  // 2 在看
  // 3 已看
  constructor(BookName:string,BookImg:string,BookLink:string,BookAuther:string) {
    this.BookName=BookName
    this.BookImg=BookImg
    this.BookLink=BookLink
    this.BookAuther=BookAuther
  }
}
export interface SearchItem {
  BookName: string;
  BookImg: string;
  BookLink: string ;
  BookAuther: string;
}
export interface GetSearchData{
  status: boolean;
  data: SearchData[];
}

