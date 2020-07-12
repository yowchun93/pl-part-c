# Public APIs

# Returns an object
# Int.new(5).toString => "5"
# Add.new(Int.new(5), Int.new(10)) => Int(15)
# Negate.new(Int.new(5)) => #<Negate:0x007feee18dc958 @e=#<Int:0x007feee18dc980 @i=5>>

# Extensibility is a double edged sword
# can make the original code more difficult to reason about locally.

class Exp
end

class Value < Exp
end

class Int < Value
  attr_reader :i
  def initialize i
    @i = i
  end
  def eval
    self
  end
  def toString
    @i.to_s
  end
  def hasZero
    i==0
  end
  def noNegConstants
    if i < 0
      Negate.new(Int.new(-i))
    else
      self
    end
  end

  # not OOP solution, but the concept is 'simpler'
  # def add_values v
  #   if v.is_a? Int
  #     Int.new(v.i + i)
  #   elsif v.is_a? MyRational
  #     # MyRational.new(v.i + v.j)
  #   else
  #     MyString.new(v.s + i.to_s)
  #   end
  # end

  # OOP solution using double dispatch
  def add_values v # first dispatch
    v.addInt self
  end
  def addInt v # second dispatch
    Int.new(v.i + i)
  end
  def addString v # second dispatch
    MyString.new(v.s + i.to_s)
  end
  def addRational v # second dispatch
    # MyRational.new(v.s + i.to_s)
  end
end

class Negate < Exp
  attr_reader :e
  def initialize e
    @e = e
  end
  def eval
    Int.new(-e.eval.i) #error if e.eval has no i method
  end
  def toString
    "-(" + e.toString + ")"
  end
  def hasZero
    e.hasZero
  end
  def noNegConstants
    Negate.new(e.noNegConstants)
  end
end

class Add < Exp
  attr_reader :e1, :e2
  def initialize(e1, e2)
    @e1 = e1
    @e2 = e2
  end
  def eval
    # Int.new(e1.eval.i + e2.eval.i)
    e1.eval.add_values e2.eval
  end
  def toString
    "(" + e1.toString + " + " + e2.toString + ")"
  end
  def hasZero
    e1.hasZero || e2.hasZero
  end
  def noNegConstants
    Add.new(e1.noNegConstants, e2.noNegConstants)
  end
end

class Mult < Exp
  attr_reader :e1, :e2
  def initialize(e1, e2)
    @e1 = e1
    @e2 = e2
  end
  def eval
    Int.new(e1.eval.i * e2.eval.i)
  end
  def toString
    "(" + e1.toString + " * " + e2.toString + ")"
  end
  def hasZero
    e1.hasZero || e2.hasZero
  end
  def noNegConstants
    Mult.new(e1.noNegConstants, e2.noNegConstants)
  end
end

class MyString < Value
  attr_reader :s
  def initialize s
    @s = s
  end
  def eval
    self
  end
  def toString
    s
  end
  def hasZero
    false
  end
  def noNegConstants
    self
  end

  # double-dispatch for adding values
  def add_values v
    v.addString self
  end
  def addInt v
    MyString.new(v.i.to_s + s)
  end
  def addString v
    # MyString.new(v.s + s)
  end
  def addRational v
    # MyString.new(v.s + s)
  end
end

class MyRational < Value
  attr_reader :i, :j
  def initialize(i,j)
    @i = i
    @j = j
  end
  def eval
    self
  end
  def toString
    i.to_s + "/" + j.to_s
  end
  def hasZero
    i == 0
  end
  def noNegConstants
    if i < 0 && j < 0
      MyRational.new(-i, -j)
    elsif j < 0
      Negate.new(MyRational.new(i, -j))
    elsif i < 0
      Negate.new(MyRational.new(-i, j))
    end
  end
end