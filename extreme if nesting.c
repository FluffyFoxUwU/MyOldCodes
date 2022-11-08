char* readable(double num, double* output) {
  static char ret[3];
  double* out = output;
  
  ret[1] = 'h';
  ret[2] = 'z';
  
  if (num >= 1000) { //KiB
    num = num / 1000;
    if (num >= 1000) { //MiB
      num = num / 1000;
      if (num >= 1000) { //GiB
        num = num / 1000;
        if (num >= 1000) { //TiB
          num = num / 1000;
          if (num >= 1000) { //PiB
            num = num / 1000;
            if (num >= 1000) { //EiB
              num = num / 1000;
              if (num >= 1000) { //ZiB
                num = num / 1000;
                ret[0] = 'Z';
                *out = num;
                return ret;
              };
              ret[0] = 'E';
              *out = num;
              return ret;
            };
            ret[0] = 'P';
            *out = num;
            return ret;
          };
          ret[0] = 'T';
          *out = num;
          return ret;
        };
        ret[0] = 'G';
        *out = num;
        return ret;
      };
      ret[0] = 'M';
      *out = num;
      return ret;
    };
    ret[0] = 'K';
    *out = num;
    return ret;
  };
  
  ret[0] = 'h';
  ret[1] = 'z';
  ret[2] = '\0';
  *out = num;
  return ret;
}
