
// 木鱼样式接口
export interface woodfishItem {
  id: number
  image: Resource
}

  export const avList: string[] = [
    'https://img02.tuke88.com/newpreview_music/09/03/88/5c8aec3410f095551.mp3',
    'https://img02.tuke88.com/newpreview_music/09/00/71/5c89465032f0c47285.mp3',
    'https://img02.tuke88.com/newpreview_music/09/03/86/5c8ae9df2794690095.mp3',
    'https://img02.tuke88.com/newpreview_music/09/03/86/5c8ae9d99b14456943.mp3',
    // 'https://img02.tuke88.com/newpreview_music/09/03/88/5c8aec307bdd858225.mp3',
    'https://dst-app-pubread.oss-cn-shenzhen.aliyuncs.com/mtc/app/images/lowcode/ji.mp3'
  ]

  // 在 Index struct 内添加木鱼数据数组
  export const woodfishList: woodfishItem[]  = [
    { id: 0, image: $r('app.media.woodfish') },
    { id: 1, image: $r('app.media.woodfish1') },
    { id: 2, image: $r('app.media.dog') },
    { id: 3, image: $r('app.media.pig') },
    { id: 4, image: $r('app.media.ji') }
  ]
