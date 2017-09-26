---
title: angular表单提交处理
p: /201709
date: 2017-09-26 09:36:42
tags:
- angular
---

对于表单页面，首次进入希望不提示错误，只有当用户修改控件内容或焦点离开时再验证，如果不合法显示错误内容。这是正常的做法。但是，如果用户进入界面后什么都不做，直接点击提交按钮，此时需要将所有控件的错误都显示处理。  
此文章介绍angualr的实现方式；

<!--more-->

# 首次进入
angular的表单控制基类AbstractControl中提供了丰富的状态字段，我们只需要其中3个状态（其他可以自行查看API文档）
- valid：是否合法
- dirty：是否是否被修改过
- touched：是否获得过焦点
通过这3个状态可以方便实现首次进入不显示错误
```typescript
if (!control.valid && (control.dirty || control.touched) ) {
    // 显示错误内容
}
```
或者直接在界面上判断
```html
    <div *ngIf="!control.valid && (control.dirty || control.touched)">
        <div *ngIf="control.hasError('required')">代码必填</div>
    </div>
```

# 提交
提交时，需要通过代码修改所有form控制器的状态为dirty（或者touched），这样是为了防止用户没有编辑而直接点击提交也能显示出控件错误。  
form控制器基类AbstractControl提供了markAsDirty方法  
```typescript
 markAsDirty(opts?: {
        onlySelf?: boolean;
    }): void;
```
通过此方法我们可以方便设置控制器的状态
```typescript
control.markAsDirty();
```
但是markAsDirty方法仅会修改当前控制器和父控制器（递归父控制器，直到parent为空）的状态，并不会修改子控制器的状态，源码如下：
```typescript
  markAsDirty(opts: {onlySelf?: boolean} = {}): void {
    (this as{pristine: boolean}).pristine = false;

    if (this._parent && !opts.onlySelf) {
      this._parent.markAsDirty(opts);
    }
  }
```
因此提交时我们需要从Form的根控制器遍历设置子控制器的状态
```typescript
  private submit(): void {
    if (!this.validateForm.valid) {
      this.markAsDirtyDeep(this.validateForm);
      return;
    }
    //submit
  }

  public markAsDirtyDeep(control: AbstractControl): void {
    if (!control) return;

    control.markAsDirty();

    if (control.hasOwnProperty('controls')) {
      let ctrl = <any>control;
      for (let inner in ctrl.controls) {
        this.markAsDirtyDeep(ctrl.controls[inner]);
      }
    }
  }
}
```
个人更喜欢下面的写法
```typescript
  private submit(): void {
    if (!this.validateForm.valid) {
      this.markAsDirtyDeep(this.validateForm);
      return;
    }
    //submit
  }

  public markAsDirtyDeep(control: AbstractControl): void {
    if (!control) return;

    control.markAsDirty();

    if (control instanceof FormGroup) {
      const ctl = <FormGroup>control;
      for (let inner in ctl.controls) {
        this.markAsDirtyDeep(ctl.get(inner));
      }
    } else if (control instanceof FormArray) {
      const ctl = <FormArray>control;
      for (let inner in ctl.controls)
        this.markAsDirtyDeep(ctl.get(inner));
    }
  }
}
```

参考：
1、https://github.com/angular/angular/issues/12281
2、https://github.com/angular/angular/issues/11774

