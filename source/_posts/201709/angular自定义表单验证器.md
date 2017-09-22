---
title: angular自定义表单验证器
p: /201709/angular自定义表单验证器.md
date: 2017-09-22 17:49:59
tags:
- angular
---
angular默认提供了一些表单验证器，比如Validators.required、Validators.minLength等，非常好用。但是有时我们有一些特殊的验证，比如代码是否存在，这样的验证就需要编写自定义表单验证器。

<!--more-->
此文章用代码是否存在作为示例，讲解angular中表单验证器如何实现。
- angular版本：4.4.3

# 编写表单验证器类
我们先编写一个代码验证器类CodeValidator，其中有一个静态方法codeExists。  
由于代码检查需要查询后台数据库，因此codeExists方法是一个异步验证器（AsyncValidatorFn） 
其中get是http调用，返回的是Observable对象，此对象包含一个data属性（具体业务数据），如果data不存在，则表示后台没有此代码。
```typescript
class CodeValidator {
  static codeExists(control: AbstractControl): Observable<ValidationErrors> {
    var service = new PoleTypeService();
    return service.get(control.value).map(result => {
      return result.data ? { codeDuplicate: true } : null;
    });
  }
}
```

自定义同步验证器写法参见：https://angular.cn/guide/form-validation#自定义验证器

# 添加表单验证器
FormControl的第2个参数是同步验证器，第3个参数是异步验证器。执行时先执行同步验证器，后执行异步验证器。  
我们定义的是异步验证器，因此传入第3个参数。
```typescript
validateForm: FormGroup;

 ngOnInit(): void {
    this.validateForm = this.fb.group({
      'code': new FormControl(this.poleType.code, [Validators.required], [CodeValidator.codeExists])
    });
  }
```

# 界面判断
我使用的是阿里[NG-ZORRO](https://ng.ant.design/#/docs/angular/introduce)控件。

```html
<div nz-form-item nz-row>
            <div nz-form-label nz-col [nzSpan]="3">
                <label nz-form-item-required>代码</label>
            </div>
            <div nz-form-control nz-col [nzSpan]="10" [nzValidateStatus]="getFormControl('code')">
                <nz-input formControlName="code" [nzPlaceHolder]="'请输入代码，保存后不可更改，请谨慎填写'"></nz-input>
                <div nz-form-explain *ngIf="getFormControl('code').invalid && (getFormControl('code').dirty || getFormControl('code').touched)">
                    <div *ngIf="getFormControl('code').errors.required">不能为空</div>
                    <div *ngIf="getFormControl('code').errors.codeDuplicate">代码已经存在</div>
                </div>
            </div>
        </div>
```

到此我们的自定义异步验证器就完成了。


