export class  FilterOptionsClass{
  type:String;//类型
  options:String[];//选项
  isMultipleChoice:boolean;
  constructor(type:String,isMultipleChoice:boolean,...options:String[]) {
    this.type=type
    this.isMultipleChoice=isMultipleChoice
    this.options=options
  }
}


export const SelectAndSaveTags=():FilterOptionsClass[]=>{
  let result:FilterOptionsClass[]=new Array()
  result=[
    new FilterOptionsClass('文库',false,'不限'),
    new FilterOptionsClass('标签',false,'不限'),
    new FilterOptionsClass('进度',false,'不限'),
    new FilterOptionsClass('动画',false,'不限'),
    new FilterOptionsClass('字数',false,'不限'),
    new FilterOptionsClass('更新',false,'不限'),
    new FilterOptionsClass('排序',false,'更新时间')
    ]
  return result
}

export const FilterOptions=():FilterOptionsClass[]=>{
  let result:FilterOptionsClass[]=new Array()
  result=[
    new FilterOptionsClass('文库',false,'不限','日本轻小说','华文轻小说','Web轻小说','轻改漫画','韩国轻小说'),
    new FilterOptionsClass('标签',true,'不限','恋爱','后宫','校园','百合','转生','异世界','奇幻','冒险','欢乐向','女性视角','龙傲天','魔法','青春','性转','病娇','妹妹','青梅竹马','战斗','NTR','人外','大小姐','黑暗','悬疑','科幻','伪娘','战争','萝莉','复仇','斗智','异能','猎奇','轻文学','职场','经营','JK','机战','女儿','末日','犯罪','旅行','惊悚','治愈','推理','日本文学','游戏','耽美','美食','群像','大逃杀','音乐','格斗','热血','温馨','脑洞','恶役','JC','间谍','竞技','宅文化','同人'),
    new FilterOptionsClass('进度',false,'不限','新书上传','情节展开','精彩纷呈','接近尾声','已经完本'),
    new FilterOptionsClass('动画',false,'不限','已动画化','未动画化'),
    new FilterOptionsClass('字数',false,'不限','30万以下','30-50万','50-100万','100-200万','200万以上'),
    new FilterOptionsClass('更新',false,'不限','三日内','七日内','半月内','一月内'),
    new FilterOptionsClass('排序',false,'周点击','月点击','周推荐','月推荐','周鲜花','月鲜花','收藏数','更新时间','入库时间'),
  ]
  return result
}