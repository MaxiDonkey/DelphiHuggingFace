# Delphi Hugging Face API

___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20the%2012/22/2024-blue)

<br/>
<br/>

- [Introduction](#Introduction)
    - [Resources available on Hugging Face Hub](#Resources-available-on-Hugging-Face-Hub)
    - [Serverless Inference API](#Serverless-Inference-API)
    - [Advantages of using Hugging Face Hub](#Advantages-of-using-Hugging-Face-Hub)
    - [Rate Limits and Supported Models](#Rate-Limits-and-Supported-Models)
    - [Licenses and Compliance](#Licenses-and-Compliance)
    - [Tutorial content](#Tutorial-content)
- [Remarks](#remarks)
- [Tools for simplifying this tutorial](#Tools-for-simplifying-this-tutorial)
- [Asynchronous callback mode management](#Asynchronous-callback-mode-management)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Hugging Face Models Overview](#Hugging-Face-Models-Overview)
        - [Model inference WARM COLD](#Model-inference-WARM-COLD)
    - [Music-gen](#Music-gen)
    - [Image object detection](#Image-object-detection)
    - [Text To Sentiment analysis](#Text-To-Sentiment-analysis)
    - [Audio classification](#Audio-classification)
        - [Speech emotion recognition](#speech-emotion-recognition)
- [Contributing](#contributing)
- [License](#license)
 
<br/>
<br/>


# Introduction

**Hugging Face Hub** is an open-source collaborative platform dedicated to democratizing access to artificial intelligence (AI) technologies. This platform hosts a vast collection of models, datasets, and interactive applications, facilitating the exploration, experimentation, and integration of AI solutions into various projects.
[Official page](https://huggingface.co/docs/hub/index)

## Resources available on Hugging Face Hub

- **Models:** The Hub offers a multitude of pre-trained models covering domains such as natural language processing (NLP), computer vision, and audio recognition. These models are suited for various tasks, including text generation, classification, object detection, and speech transcription. 
- **Datasets:** A diverse library of datasets is available for training and evaluating your own models, providing a foundation for developing customized solutions. 
- **Spaces:** The Hub hosts interactive applications that allow you to visualize and test models directly from a browser. These spaces are useful for demonstrating model capabilities or conducting quick analyses. 

<br/>

## Serverless Inference API

Hugging Face Hub offers a Inference API, enabling rapid integration of AI models into your projects without the need for complex infrastructure management.

<br/>

## Advantages of using Hugging Face Hub

- **Time-saving:** Models are ready to use, eliminating the need to train or deploy them locally, which accelerates the development of applications.
- **Scalability:** The Hub's infrastructure ensures automatic scaling, load balancing, and efficient caching.

<br/>

In summary, **Hugging Face Hub** is a resource for integrating AI models into projects. With its serverless Inference API and collection of ready-to-use resources, it offers an solution to enhance applications with AI capabilities while simplifying their implementation and maintenance.

<br/>

## Rate Limits and Supported Models

By subscribing, you gain access to thousands of models. You can explore the benefits of individual, professional, and enterprise subscriptions by following the links below:

- [Rate limits](https://huggingface.co/docs/api-inference/rate-limits)
- [Supported models](https://huggingface.co/docs/api-inference/supported-models)

<br/>

## Licenses and Compliance

When integrating models or datasets from **Hugging Face Hub** into your projects, it is crucial to pay close attention to the associated licenses. Every resource hosted on the platform comes with a specific license that outlines the terms of use, modification, and distribution. A thorough understanding of these licenses is essential to ensure the legal and ethical compliance of your developments.

**Why is this important?**

- **Legal compliance:** Using a resource without adhering to its license terms can lead to legal violations, exposing your project to potential risks.
- **Respect for creators' rights:** Licenses protect the rights of creators. By respecting them, you acknowledge and honor their work.
- **Transparency and ethics:** Following the conditions of licenses promotes responsible and ethical use of open-source technologies.

Refer to the `Model Card` or `Dataset Card` for each model or dataset used in your application.

<br/>

## Tutorial content

The **Hugging Face Hub** provides open-source libraries such as `Transformers`, enables integration with `Gradio`, and offers evaluation tools like `Evaluate`. However, these aspects will not be covered in this tutorial, as they are beyond the scope of this document.

Instead, this tutorial will focus on using the APIs with Delphi, highlighting key features such as image and sound classification, music generation (`music-gen`), sentiment analysis, object detection in images, image segmentation, and all natural language processing (NLP) functions.

<br/>

# Remarks

> [!IMPORTANT]
>
> This is an unofficial library. **Hugging Face** does not provide any official library for `Delphi`.
> This repository contains `Delphi` implementation over [Hugging Face](https://huggingface.co/docs/api-inference) public API.

<br/>

# Tools for simplifying this tutorial

To simplify the example codes provided in this tutorial, I have included two units in the source code: `VCL.Stability.Tutorial` and `FMX.Stability.Tutorial`. Depending on the option you choose to test the provided source code, you will need to instantiate either the `TVCLStabilitySender` or `TFMXStabilitySender` class in the application's `OnCreate` event, as follows:

>[!TIP]
>```Pascal
>//uses VCL.HuggingFace.Tutorial;
>
>  HFTutorial := TVCLHuggingFaceSender.Create(Memo1, Image1, Image2, MediaPlayer1);
>```
>
>or
>
>```Pascal
>//uses FMX.HuggingFace.Tutorial;
>
>  HFTutorial := TFMXHuggingFaceSender.Create(Memo1, Image1, Image2, MediaPlayer1);
>```
>

Make sure to add a `TMemo`, two `TImage` and a `TMediaPlayer` component to your form beforehand.

<br/>

# Asynchronous callback mode management

In the context of asynchronous methods, for a method that does not involve streaming, callbacks use the following generic record: `TAsynCallBack<T> = record` defined in the `HuggingFace.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject, T>;
       OnError: TProc<TObject, string>; 
```
<br/>

For methods requiring streaming, callbacks use the generic record `TAsynStreamCallBack<T> = record`, also defined in the `HuggingFace.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject>;
       OnProgress: TProc<TObject, T>;
       OnError: TProc<TObject, string>;
       OnCancellation: TProc<TObject>;
       OnDoCancel: TFunc<Boolean>;
```

The name of each property is self-explanatory; if needed, refer to the internal documentation for more details.

<br/>

# Usage

## Initialization

To initialize the API instance, you need to [obtain an API key from Hugging Face](https://huggingface.co/settings/tokens).

Once you have a token, you can initialize the `IHuggingFace` interface, which serves as the entry point to the API.

> [!NOTE]
>```Pascal
>uses HuggingFace;
>
>var HuggingFace := THuggingFaceFactory.CreateInstance(API_KEY);
>```

When accessing the `list of models` or retrieving the `description of a specific model`, a different endpoint is used than the API endpoint. To instantiate this interface, use the following code:

```Pascal
uses HuggingFace;

var HFHub := THuggingFaceFactory.CreateInstance(API_KEY, True);
```

>[!Warning]
> To use the examples provided in this tutorial, especially to work with asynchronous methods, I recommend defining the HuggingFace interface with the widest possible scope.
><br/>
> So, set `HuggingFace := THuggingFaceFactory.CreateInstance(My_Key);` in the `OnCreate` event of your application.
><br>
>Where `HuggingFace: IHuggingFace;`

<br/>

## Hugging Face Models Overview

A filtered list of models can be obtained directly from the [playground](https://huggingface.co/spaces/enzostvs/hub-api-playground) or access to search models page on [web site.](https://huggingface.co/models) 
<br/><br/>
Using **Delphi**, this list can also be retrieved programmatically. To support filtering, the `TFetchParams` class, implemented in the `HuggingFace.Hub.Support` unit, must be used. This class accurately mirrors all parameters supported by the `/api/models` endpoint.


<br/>

**Synchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  var Models := HF.Hub.FetchModels(HFTutorial.UrlNext,
    procedure (Params: TFetchParams)
    begin
      Params.Limit(50);
      Params.Filter('eng,text-generation');
    end);
  try
    Display(HFTutorial, Models);
  finally
    Models.Free;
  end;
```

- **Remark :** A paginated result will be returned, containing 50 models per page. 
The `HFTutorial.UrlNext` variable will store the URL of the next page. By re-executing this code, the next 50 results will be retrieved and displayed.

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HF.Hub.FetchModels(HFTutorial.UrlNext,
    procedure (Params: TFetchParams)
    begin
      Params.Limit(50);
      Params.Filter('text-to-audio');
    end,
    function : TAsynModels
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

>[!TIP]
> The filter parameter queries the `Tags` field in the models' JSON format. Use a comma to separate different `Tags` values to include them in the same filter.
>

<br/>

To visualize a model's data, utilize its model ID with the FetchModel method :

```Pascal
  //Synchronously
  function FetchModel(const RepoId: string): TRepoModel; overload;

  //Asynchronously
  procedure FetchModel(const RepoId: string; CallBacks: TFunc<TAsynRepoModel>); overload;
```

<br/>

### Model inference WARM COLD

The ML ecosystem evolves rapidly, and the Inference API provides access to models highly valued by the community, selected based on their recent popularity (likes, downloads, and usage). As a result, the available models may be replaced at any time without prior notice. Hugging Face strives to keep the most recent and popular models ready for immediate use.

The following distinctions are made:

- **Warm models:** models that are ready to use.
- **Cold models:** models that require loading before use.
- **Frozen models:** models currently unavailable for use via the API.

When invoking a model in the `COLD` state, it needs to be reloaded, which may result in a 503 error. In this case, you must wait before retrying the request with the same model.
To avoid the 503 error and wait for the model to reload and transition to the `WARM` state, you can add the following line of code:

```Pascal
  HuggingFace.WaitForModel := True;
```

Note : By default, the value of `WaitForModel` is set to False.

Refer to [official documentation](https://huggingface.co/docs/api-inference/parameters)

<br/>

## Music-gen

[MusicGen](https://huggingface.co/facebook/musicgen-small) is a text-to-music model capable of genreating high-quality music samples conditioned on text descriptions or audio prompts.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.UseCache := False;  //Disable caching
  HuggingFace.WaitForModel := True;  //Enable waiting for model reloading
  HFTutorial.FileName := 'music.mp3';

  HuggingFace.Text.TextToAudio(
    procedure (Params: TTextToAudioParam)
    begin
      Params.Model('facebook/musicgen-small');
      Params.Inputs('Pop music style with bass guitar');
    end,
    function : TAsynTextToSpeech
    begin
      Result.Sender := HFTutorial;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Image object detection

[DEtection TRansformer (DETR) model](https://huggingface.co/facebook/detr-resnet-50) trained end-to-end on COCO 2017 object detection (118k annotated images).
The DETR model is an encoder-decoder transformer with a convolutional backbone.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  var ImageFilePath := 'Z:\My_Folder\Images\My_Image.jpg';
  HFTutorial.LoadImageFromFile(ImageFilePath);
  HuggingFace.WaitForModel := True;

  HuggingFace.Image.ObjectDetection(
    procedure (Params: TObjectDetectionParam)
    begin
      Params.Model('facebook/detr-resnet-50');
      Params.Inputs(ImageFilePath);
    end,
    function : TAsynObjectDetection
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

![Alt text](/../main/images/ObjectDetection.png?raw=true "Object detection")

<br/>

## Text To Sentiment analysis

This is a [RoBERTa-base model](https://huggingface.co/cardiffnlp/twitter-roberta-base-sentiment-latest) trained on ~124M tweets from January 2018 to December 2021, and finetuned for sentiment analysis with the TweetEval benchmark. 

- **Reference Paper:** [TimeLMs paper](https://arxiv.org/abs/2202.03829).
- **Git Repo:** [TimeLMs official repository](https://github.com/cardiffnlp/timelms).

Labels: 0 -> Negative; 1 -> Neutral; 2 -> Positive

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text. SentimentAnalysis(
    procedure (Params: TSentimentAnalysisParams)
    begin
      Params.Model('cardiffnlp/twitter-roberta-base-sentiment-latest');
      Params.Inputs('Today is a great day');
    end,
    function : TAsynSentimentAnalysis
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Audio classification

### Speech emotion recognition

[Speech Emotion Recognition By Fine-Tuning Wav2Vec 2.0](https://huggingface.co/ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition) <br/>
The model is a fine-tuned version of `jonatasgrosman/wav2vec2-large-xlsr-53-english` for a Speech Emotion Recognition (SER) task.

The dataset used to fine-tune the original pre-trained model is the RAVDESS dataset. This dataset provides 1440 samples of recordings from actors performing on 8 different emotions in English, which are:

```Text 
  emotions = ['angry', 'calm', 'disgust', 'fearful', 'happy', 'neutral', 'sad', 'surprised']
```

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Audio.Classification(
    procedure (Params: TAudioClassificationParam)
    begin
      Params.Model('ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition');
      Params.Inputs('VoiceRecorded.wav');
    end,
    function : TAsynAudioClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

<br/>

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.