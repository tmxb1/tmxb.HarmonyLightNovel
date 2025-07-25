export interface GetDetailed {
  status: boolean;
  data: BookData;
}

export interface  BookData{
  BookSynopsis: string;
  BookImg: string,
  BookName: string,
  BookAuthor: string,
  BookLastTime: string,
  BookOver:string,
  BookWordage: string,
  SumRecommend: string,
  WeekRecommend: string,
  AnimationBased: string,
  BookTags: string[]
}