using UnityEngine;
using Random = System.Random;

public class AudioGenerator: MonoBehaviour {
  private Random rand = new Random(); 

  private int sampleRate = 48000;
  private int time = 0;
  public int position = 0;
  public int samplerate = 44100;
  public float frequency = 440;

  void Start() {
        AudioClip myClip = AudioClip.Create("MySinusoid", samplerate * 2, 1, samplerate, true, OnAudioRead, OnAudioSetPosition);
        AudioSource aud = GetComponent<AudioSource>();
        aud.clip = myClip;
        aud.Play();
  }
  float GetSinWave(int index, float frequency, int sampleRate) {
    return Mathf.Sin(2 * Mathf.PI * (index / (float) sampleRate) * frequency);
  }

  void OnAudioRead(float[] data)
  {
      int count = 0;
      while (count < data.Length)
      {
          data[count] = Mathf.Sin(2 * Mathf.PI * frequency * position / samplerate);
          position++;
          count++;
      }
  }

  void OnAudioSetPosition(int newPosition)
  {
      position = newPosition;
  }


  private void OnAudioFilterRead(float[] data, int channels) {
    Debug.Log("OnAudioFilterRead");
    // looping through each sample group
    for (int i = 0; i < data.Length; i += channels) {
      // looping through sample of each channel in sample group
      for (int j = 0; j < channels; j++) {
        data[i + j] = GetSinWave(time, frequency, sampleRate);
      }

      time++; // increase sample count in each call

      // resetting wave every 5 sec to avoid overflow in float
      if (time >= sampleRate * 5) {
        time = 0;
      }
    }
  }
}