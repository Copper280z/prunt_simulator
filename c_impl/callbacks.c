#include <stdio.h>

void enable_stepper(int axis_id) { printf("Enable stepper: %d\n", axis_id); }

void disable_stepper(int axis_id) { printf("Disable stepper: %d\n", axis_id); }

void enqueue_command(float x, float y, float z, float e, int index,
                     int safe_stop) {
  (void) index;
  printf("Move to: X=%.2f Y=%.2f Z=%.2f E=%.2f\n", x, y, z, e);
  if (safe_stop) {
    printf("Safe stop after this move\n");
  }
}

void configure(float interp_time) {
  printf("Configuring with interp time: %.3f\n", interp_time);
}

void shutdown() {
  printf("Shutdown!\n");
}
