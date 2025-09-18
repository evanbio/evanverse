# 🚀 快速分支保护设置

## 立即操作（5分钟完成）

### 1. 访问分支保护页面
点击这个直接链接：https://github.com/evanbio/evanverse/settings/branches

### 2. 创建main分支保护规则
点击 **"Add rule"** 按钮，设置：

**基本设置：**
- Branch name pattern: `main`
- ✅ Include administrators

**关键保护规则：**
- ✅ **Require a pull request before merging**
  - Required approvals: `0` (单人开发可设为0)
  - ✅ Dismiss stale reviews when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
- ✅ **Require conversation resolution before merging**
- ❌ **Allow force pushes** (保持禁用)
- ❌ **Allow deletions** (保持禁用)

### 3. 点击 "Create" 保存设置

## ✅ 设置完成后的效果

- 🛡️ 无法直接推送到main分支
- 📋 所有更改必须通过PR
- 🤖 CI检查必须通过才能合并
- 🔒 main分支保持稳定状态

## 🎯 下一步
设置完成后，回到命令行继续测试流程！

## 🧪 CI/CD流水线测试
此文件的更新将触发GitHub Actions测试：
- ✅ R-CMD-check on multiple platforms
- ✅ Test coverage reporting
- ✅ Documentation build verification

*测试时间：* $(date)