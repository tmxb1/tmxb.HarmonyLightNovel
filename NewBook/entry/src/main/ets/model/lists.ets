import dataPreferences from '@ohos.data.preferences';
import Ability from '@ohos.app.ability.UIAbility';
export interface lists{
  title:string;//书名
  img:string;//书面
  Booklink:string;//id，地址
  type:number; //类型
}

const STORAGE_KEY = 'appStoreData';
const PREF_NAME = 'myAppPreferences';
// 全局状态管理类

@ObservedV2
export class AppStore {
  @Trace data: lists[] = [{"img":"https://www.linovelib.com/files/article/image/4/4759/4759s.jpg?450323","title":"失恋同居 ～女同学拒绝了我的告白后，住进了我家？","Booklink":"https://www.linovelib.com/novel/4759.html","type":2}];
  @Trace showAgreementDialog:boolean=false;
  private context: Ability | null = null;

  // 初始化时注入Ability上下文
  setContext(context: Ability) {
    this.context = context;
    this.loadFromLocal();
  }

  async loadFromLocal() {
    if (!this.context) return;

    try {
      const pref = await dataPreferences.getPreferences(this.context.context, PREF_NAME);

      // 加载数据
      const storedData = await pref.get(STORAGE_KEY, '[]');
      this.data = JSON.parse(storedData as string);

      // 加载用户协议状态（默认显示）
      this.showAgreementDialog = await pref.get('showAgreementDialog', false) as boolean;

      console.log('从本地加载数据成功');
    } catch (err) {
      console.error(`数据加载失败: ${err.code}, ${err.message}`);
    }
  }

  // 保存数据到本地
  async saveToLocal() {
    if (!this.context) return;

    try {
      const pref = await dataPreferences.getPreferences(this.context.context, PREF_NAME);

      // 保存数据
      await pref.put(STORAGE_KEY, JSON.stringify(this.data));

      // 保存用户协议状态
      await pref.put('showAgreementDialog', this.showAgreementDialog);

      await pref.flush();
      console.log('数据保存成功');
    } catch (err) {
      console.error(`数据保存失败: ${err.code}, ${err.message}`);
    }
  }

  addItem(book:lists) {
    this.data.push(book)
    console.log('lists:',JSON.stringify(this.data))
  }

  forceUpdate() {
    this.data = [...this.data]; // 手动触发更新
  }

  deleteItem(title:string) {
    this.data = this.data.filter(item => item.title !== title);
  }

  ChangeType(title: string,tpye:number) {
    this.data = this.data.map(item => {
      // 使用点表示法访问属性
      if (item.title === title) {
        // 创建新对象并更新 type 属性
        const newType = tpye;
        return {
          title: item.title,      // 复制 title
          img: item.img,          // 复制 img
          Booklink: item.Booklink, // 复制 Booklink
          type: newType           // 更新 type
        };
      }
      return item; // 不匹配的项保持不变
    });
  }

}

// 创建并导出单例实例
export const appStore = new AppStore();
appStore.forceUpdate();