---
title: redis分布式事务锁样例代码
p: 201909/redis分布式事务锁样例代码
date: 2019-09-05 09:40:18
tags: redis
---
在多线程环境下，对于某个特殊资源，希望能够排队使用，可以通过redis锁的方式实现，下面是样例代码。

<!--more-->

```java
/**
 * redis分布式事务锁工具
 *
 * @author alex
 * alex 在 2019-06-18 18:32 创建。
 */
@Component
public class RedisLockerUtil {
  private static final RedisScript<Boolean> LOCK_SCRIPT;
  private static final RedisScript<Boolean> UN_LOCK_SCRIPT;

  static {
    String sb = "if (redis.call('setnx', KEYS[1], ARGV[1]) == 1) then return redis.call('expire', KEYS[1], tonumber(ARGV[2])) == 1 else return false end";
    LOCK_SCRIPT = new DefaultRedisScript<>(sb, Boolean.class);
  }

  static {
    String sb = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) == 1 else return false end";
    UN_LOCK_SCRIPT = new DefaultRedisScript<>(sb, Boolean.class);
  }

  @Autowired
  private RedisTemplate<Object, Object> redisTemplate;


  public boolean tryLock(String key, String sessionId) {
    return tryLock(key, sessionId, 60, 10, 1000);
  }

  /**
   * 加锁
   *
   * @param key           锁主键
   * @param sessionId     客户SessionId，正常传入一个随机UUID
   * @param expireSeconds 锁的有效时长（秒）
   * @param retryTimes    加锁重试次数
   * @param sleepMills    加锁重试间隔（毫秒）
   * @return 加锁成功返回true
   */
  public boolean tryLock(String key, String sessionId, long expireSeconds, int retryTimes, int sleepMills) {
    if (StringUtils.isBlank(key))
      throw new IllegalArgumentException("key不能为空");
    if (StringUtils.isBlank(sessionId))
      throw new IllegalArgumentException("sessionId不能为空");


    boolean lock = doLock(key, sessionId, expireSeconds);
    while (!lock && retryTimes > 0) {
      try {
        Thread.sleep(sleepMills);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      lock = doLock(key, sessionId, expireSeconds);
      retryTimes--;
    }
    return lock;
  }


  /**
   * 释放锁
   *
   * @param key       锁主键
   * @param sessionId 客户SessionId，需要传入加锁时的sessionId
   * @return 释放成功返回true
   */
  public boolean releaseLock(String key, String sessionId) {
    Object object = redisTemplate.execute(UN_LOCK_SCRIPT, Collections.singletonList(key), sessionId);
    return (Boolean) object;
  }

  private Boolean doLock(String key, String sessionId, long expireSeconds) {
    Object object = redisTemplate.execute(LOCK_SCRIPT, Collections.singletonList(key), sessionId, expireSeconds);
    return (Boolean) object;
  }

}
```