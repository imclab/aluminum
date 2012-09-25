#ifndef INCLUDE_ALU_BEHAVIOR_HPP
#define INCLUDE_ALU_BEHAVIOR_HPP

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <list>

namespace aluminum {

  using std::list;
  using glm::dvec3;
  using glm::vec2;
  using glm::vec3;
  using glm::vec4;
  using glm::mat4;

  class Easing {
    public:
      enum EASE {IN, OUT, IN_OUT, OUT_IN};
      EASE ease;
      
      virtual double in(double perc) {
	printf("in virtual in...\n");
	return perc;
      }
      virtual double out(double perc) = 0; // {return perc;}
      virtual double inout(double perc) = 0; //{return perc;}
      virtual double outin(double perc) = 0; //{return perc;}

      Easing() {}
      Easing(EASE _ease) {
	ease = _ease;
      }
  
  };

  class EasingSine : public Easing {
    public:
      
      EasingSine() {}
      EasingSine(Easing::EASE _ease) : Easing(_ease) {
      }

      virtual double in(double perc) {
	printf("in easingSine : in...\n");
	return -cos(perc * (M_PI * .5)) + 1;
      }

      virtual double out(double perc) {
	return sin(perc * M_PI * .5);
      }

      virtual double inout(double perc) {
	return (-.5 * (cos(M_PI * perc) - 1));
      }

      virtual double outin(double perc) {
	if (perc < .5f) {
	  return (.5 * sin(M_PI * perc));
	} else {
	  return 1.0 - (.5 * sin(M_PI * perc));
	}
      }


  };

  class Behavior {

    public:

      Behavior();
      ~Behavior();

      //builder
      Behavior(long startTime);
      Behavior& looping(bool _is);
      Behavior& reversing(bool _is);
      Behavior& repeats(int _n);
      Behavior& length(long _ms);
      Behavior& delay(long _ms);
      Behavior& range(vec3 _r);
      Behavior& range(float _r);
      //Behavior& easing(Easing* _e);
      Behavior& easing(Easing _e);

      //update
      Behavior& tick(long _tick);

      //get values
      float offset();
      vec3 offsets();
      float total();
      vec3 totals();

      //control
      bool isScheduled;
      bool isActive;
      bool isDone;


    protected:
      void init();

      double calculateOffsetPercentage(double perc, double prevPerc, int dir);
      double getRawPercentage(long currentNano, long loopNano);

      long loopLength;
      double percentage;
      double prevPercentage;
      double offsetPercentage;
      long overshoot;
      vec3 ranges;

      void loopBehavior();
      void reverseBehavior();
      //bool timeToLoop;

      Easing* m_easing;
      
      vec3 m_offsets;
      vec3 m_totals;

      int repeat;
      int numRepeats;
      int dir;

      long nextTime;

      bool isEasing;
      bool isLooping;
      bool isReversing;

    private:
  };

}

#endif



