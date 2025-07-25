///| Return exponent of x 
///
/// # Example
///
/// ```moonbit
/// assert_eq(exp(1), 2.718281828459045)
/// assert_eq(exp(-1), 0.36787944117144233)
/// assert_eq(exp(-2), 0.1353352832366127)
/// assert_eq(exp(-3), 0.049787068367863944)
/// ```
///
/// # Accuracy:
/// 
/// 1 ulp (unit in the last place).
///
/// # Special cases:
///
/// 1. exp(INF) is INF, exp(NaN) is NaN;
/// 2. exp(-INF) is 0, and
/// 3. for finite argument, only exp(0)=1 is exact.
pub fn exp(input : Double) -> Double {
  let mut x = input
  let one = 1.0
  let halF = [0.5, -0.5]
  let o_threshold = 7.09782712893383973096e+02
  let u_threshold = -7.45133219101941108420e+02
  let ln2HI = [6.93147180369123816490e-01, -6.93147180369123816490e-01]
  let ln2LO = [1.90821492927058770002e-10, -1.90821492927058770002e-10]
  let invln2 = 1.44269504088896338700e+00
  let p1 = 1.66666666666666019037e-01
  let p2 = -2.77777777770155933842e-03
  let p3 = 6.61375632143793436117e-05
  let p4 = -1.65339022054652515390e-06
  let p5 = 4.13813679705723846039e-08
  let e = 2.718281828459045
  let mut hi = 0.0
  let mut lo = 0.0
  let huge = 1.0e+300
  let twom1000 = 9.33263618503218878990e-302
  let two1023 = 8.988465674311579539e307
  let mut k : Int = 0
  let mut hx : UInt = __hi(input)
  let xsb : Int = ((hx >> 31) & 1).reinterpret_as_int()
  hx = hx & 0x7FFFFFFF
  if hx >= 0x40862E42 {
    if hx >= 0x7FF00000 {
      let lx : UInt = __low(input)
      if ((hx & 0xFFFFF) | lx) != 0 {
        return input + input
      } else if xsb == 0 {
        return input
      } else {
        return 0.0
      }
    }
    if input > o_threshold {
      return huge * huge
    }
    if input < u_threshold {
      return twom1000 * twom1000
    }
  }
  if hx > 0x3FD62E42 {
    if hx < 0x3FF0A2B2 {
      if input == 1.0 {
        return e
      }
      hi = input - ln2HI[xsb]
      lo = ln2LO[xsb]
      k = 1 - xsb - xsb
    } else {
      k = (invln2 * input + halF[xsb]).to_int()
      let t = k.to_double()
      hi = input - t * ln2HI[0]
      lo = t * ln2LO[0]
    }
    x = hi - lo
  } else if hx < 0x3E300000 {
    if huge + x > one {
      return one + x
    }
  } else {
    k = 0
  }
  let t = x * x
  let twopk = if k >= -1021 {
    __combine(
      (0x3FF00000 + (k.reinterpret_as_uint() << 20).reinterpret_as_int())
      .to_int64()
      .reinterpret_as_uint64(),
      0,
    )
  } else {
    __combine(
      0x3FF00000UL + ((k + 1000).reinterpret_as_uint() << 20).to_uint64(),
      0,
    )
  }
  let c = x - t * (p1 + t * (p2 + t * (p3 + t * (p4 + t * p5))))
  if k == 0 {
    return one - (x * c / (c - 2.0) - x)
  }
  let y = one - (lo - x * c / (2.0 - c) - hi)
  if k >= -1021 {
    if k == 1024 {
      return y * 2.0 * two1023
    } else {
      return y * twopk
    }
  } else {
    return y * twopk * twom1000
  }
}

///|
test "exp" {
  fn assert_exp_ulp(input, expect) raise {
    assert_ulp(expect, exp(input), EXP_MAX_ULP)
  }

  assert_exp_ulp(-1, 0.36787944117144233)
  assert_exp_ulp(-2, 0.1353352832366127)
  assert_exp_ulp(-3, 0.049787068367863944)
  assert_exp_ulp(-4, 0.01831563888873418)
  assert_exp_ulp(-5, 0.006737946999085467)
  assert_exp_ulp(-6, 0.0024787521766663585)
  assert_exp_ulp(-7, 0.0009118819655545162)
  assert_exp_ulp(-8, 0.00033546262790251185)
  assert_exp_ulp(-9, 0.00012340980408667956)
  assert_exp_ulp(1, 2.718281828459045)
  assert_exp_ulp(2, 7.38905609893065)
  assert_exp_ulp(3, 20.085536923187668)
  assert_exp_ulp(4, 54.598150033144236)
  assert_exp_ulp(5, 148.4131591025766)
  assert_exp_ulp(6, 403.4287934927351)
  assert_exp_ulp(7, 1096.6331584284585)
  assert_exp_ulp(8, 2980.9579870417283)
  assert_exp_ulp(9, 8103.083927575384)
  assert_exp_ulp(10, 22026.465794806718)
  assert_exp_ulp(100, 26881171418161356000000000000000000000000000)
  assert_exp_ulp(1000, @double.infinity)
  assert_exp_ulp(10000, @double.infinity)
  assert_exp_ulp(2.5, 12.182493960703473)
  assert_exp_ulp(3.4, 29.96410004739701)
  assert_exp_ulp(5.3, 200.33680997479166)
  assert_exp_ulp(6.2, 492.7490410932563)
  assert_exp_ulp(7.1, 1211.9670744925763)
  assert_exp_ulp(8.9, 7331.973539155995)
  assert_exp_ulp(9.8, 18033.744927828524)
  assert_exp_ulp(10.7, 44355.85513029784)
  assert_exp_ulp(101.6, 133143313639875650000000000000000000000000000)
  assert_exp_ulp(1.542, 4.673928786933209)
  assert_exp_ulp(2.846, 17.218768831241345)
  assert_exp_ulp(7.881, 2646.517754639287)
  assert_exp_ulp(3.772, 43.466911783522)
  assert_exp_ulp(-1.542, 0.21395276770062824)
  assert_exp_ulp(-2.846, 0.0580761615305284)
  assert_exp_ulp(-7.881, 0.0003778550127793483)
  assert_exp_ulp(-3.772, 0.023006005234056975)
  assert_exp_ulp(-1, 0.36787944117144233)
  assert_exp_ulp(0, 1)
  assert_exp_ulp(-0, 1)
  assert_exp_ulp(@double.not_a_number, @double.not_a_number)
  assert_exp_ulp(@double.infinity, @double.infinity)
  assert_exp_ulp(@double.neg_infinity, 0)
}
