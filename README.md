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
- [Exploration Journey](#Exploration-Journey)
    - [Initialization](#initialization)
    - [Hugging Face Models Overview](#Hugging-Face-Models-Overview)
        - [Model inference WARM COLD](#Model-inference-WARM-COLD)
    - [Music-gen](#Music-gen)
    - [Image object detection](#Image-object-detection)
    - [Text To Sentiment analysis](#Text-To-Sentiment-analysis)
    - [Audio classification](#Audio-classification)
        - [Speech emotion recognition](#speech-emotion-recognition)
        - [Gender recognition](#Gender-recognition)
    - [Image classification](#Image-classification)
    - [Image Segmentation](#Image-Segmentation)
    - [Zero-Shot classification](#Zero-Shot-classification)
    - [Token Classification](#Token-Classification)
    - [Question Answering](#Question-Answering)
    - [Table Question Answering](#Table-Question-Answering)
    - [Fill-mask](#Fill-mask)
    - [Text Classification](#Text-Classification)
    - [Summarization](#Summarization)
- [Common Ground Functionalities Across API Ecosystems](#Common-Ground-Functionalities-Across-API-Ecosystems)
    - [Embeddings](#Embeddings)
    - [Chat](#Chat)
        - [Multi Turn Conversation](#Multi-Turn-Conversation)
        - [Streamed Multi Turn Conversation](#Streamed-Multi-Turn-Conversation)
        - [Vision](#Vision)
        - [Use tools](#Use-tools)
    - [Text Generation](#Text-Generation)
    - [Translation](#Translation)
    - [Image Generation](#Image-Generation)
    - [Text-to-Speech](#Text-to-Speech)
    - [Automatic Speech Recognition](#Automatic-Speech-Recognition)
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

# Exploration Journey

This part of this document is designed to reflect the path I took while uncovering the features and possibilities of `Hugging Face Hub APIs`. Rather than presenting a rigid tutorial, I chose to structure it as an **Exploration Journey** to capture the iterative, curious, and hands-on process of discovery. Each step builds on the previous one, showcasing not only what I found but how I approached and learned from the API ecosystem."


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

  var Models := HFHub.Hub.FetchModels(HFTutorial.UrlNext,
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

  HFHub.Hub.FetchModels(HFTutorial.UrlNext,
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

[MusicGen](https://huggingface.co/facebook/musicgen-small) is a text-to-music model capable of generating high-quality music samples conditioned on text descriptions or audio prompts.

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

For more details about the `object-detection` task, check out its [dedicated page](https://huggingface.co/tasks/object-detection)! You will find examples and related materials.

>[!NOTE]
> In the field of `Object Detection`, over 2,913 pre-trained models are available. 
>

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

![Object detection](/../main/images/ObjectDetection.png?raw=true "Object detection")

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

For more details about the `audio-classification` task, check out its [dedicated page](https://huggingface.co/tasks/audio-classification)! You will find examples and related materials.

<br/>

>[!NOTE]
> In the field of `Audio Classification`, over 2,859 pre-trained models are available. 
>

### Speech emotion recognition

[Speech Emotion Recognition By Fine-Tuning Wav2Vec 2.0](https://huggingface.co/ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition) <br/>
The model is a fine-tuned version of `jonatasgrosman/wav2vec2-large-xlsr-53-english` for a Speech Emotion Recognition (SER) task.

The dataset used to fine-tune the original pre-trained model is the RAVDESS dataset. This dataset provides 1440 samples of recordings from actors performing on 8 different emotions in English, which are:

```Python
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
      Params.Inputs('SpeechRecorded.wav');
    end,
    function : TAsynAudioClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Gender recognition

[wav2vec2-large-xlsr-53-gender-recognition-librispeech](https://huggingface.co/alefiury/wav2vec2-large-xlsr-53-gender-recognition-librispeech) <br/><br/>
This model is a fine-tuned version of facebook/wav2vec2-xls-r-300m on Librispeech-clean-100 for gender recognition.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Audio.Classification(
    procedure (Params: TAudioClassificationParam)
    begin
      Params.Model('alefiury/wav2vec2-large-xlsr-53-gender-recognition-librispeech');
      Params.Inputs('SpeechRecorded.wav');
    end,
    function : TAsynAudioClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Image classification

For more details about the `image-classification` task, check out its [dedicated page](https://huggingface.co/tasks/image-classification)! You will find examples and related materials.

>[!NOTE]
> In the field of `image classification`, over 15,000 pre-trained models are available.
>

[ResNet-50 v1.5](https://huggingface.co/microsoft/resnet-50) <br/>
ResNet model pre-trained on ImageNet-1k at resolution 224x224. It was introduced in the paper [Deep Residual Learning for Image Recognition](https://arxiv.org/abs/1512.03385) by He et al.

ResNet (Residual Network) is a convolutional neural network that democratized the concepts of residual learning and skip connections. This enables to train much deeper models.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  var ImageFilePath := 'images\tiger.jpg';
  HFTutorial.LoadImageFromFile(ImageFilePath);
  HuggingFace.WaitForModel := True;

  HuggingFace.Image.Classification(
    procedure (Params: TImageClassificationParam)
    begin
      Params.Model('microsoft/resnet-50');
      //Params.Model('google/vit-base-patch16-224');  //Can be used too
      Params.Inputs(ImageFilePath);
    end,
    function : TAsynImageClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

[Vision Transformer (base-sized model)](https://huggingface.co/google/vit-base-patch16-224)
Vision Transformer (ViT) model pre-trained on ImageNet-21k (14 million images, 21,843 classes) at resolution 224x224, and fine-tuned on ImageNet 2012 (1 million images, 1,000 classes) at resolution 224x224. It was introduced in the paper An Image is Worth 16x16 Words: [Transformers for Image Recognition at Scale](https://arxiv.org/abs/2010.11929) by Dosovitskiy et al. and first released in this repository. 

<br/>

## Image Segmentation

For more details about the `image-segmentation` task, check out its [dedicated page](https://huggingface.co/tasks/image-segmentation)! You will find examples and related materials.

>[!NOTE]
> In the field of `image segmentation`, over 1,093 pre-trained models are available. Each model is distinguished by specific skills.
>

[openmmlab/upernet-convnext-small](https://huggingface.co/openmmlab/upernet-convnext-small) <br/>
UperNet framework for semantic segmentation, leveraging a ConvNeXt backbone. UperNet was introduced in the paper [Unified Perceptual Parsing for Scene Understanding](https://arxiv.org/abs/1807.10221) by Xiao et al.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  var ImageFilePath := 'images\tiger.jpg';
  HFTutorial.LoadImageFromFile(ImageFilePath);
  HuggingFace.WaitForModel := True;

  HuggingFace.Image.Segmentation(
    procedure (Params: TImageSegmentationParam)
    begin
      Params.Model('openmmlab/upernet-convnext-small');
      Params.Inputs(ImageFilePath);
    end,
    function : TAsynImageSegmentation
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

![Image segmentation](/../main/images/ImageSegmentation.png?raw=true "Image segmentation")

<br/>

Other models that you can easily test. It is up to you to choose the most suitable image:
- [jonathandinu/face-parsing](https://huggingface.co/jonathandinu/face-parsing)
- [nvidia/segformer-b1-finetuned-cityscapes-1024-1024](https://huggingface.co/nvidia/segformer-b1-finetuned-cityscapes-1024-1024)
- [google/deeplabv3_mobilenet_v2_1.0_513](https://huggingface.co/google/deeplabv3_mobilenet_v2_1.0_513)
- [facebook/mask2former-swin-large-cityscapes-semantic](https://huggingface.co/facebook/mask2former-swin-large-cityscapes-semantic)

<br/>

## Zero-Shot classification

For more details about the `zero-shot-classification` task, check out its [dedicated page](https://huggingface.co/tasks/zero-shot-classification)! You will find examples and related materials.

>[!NOTE]
> In the field of `Zero-shot classification`, over 337 pre-trained models are available. 
>

[facebook/bart-large-mnli](https://huggingface.co/facebook/bart-large-mnli) <br/>
This is the checkpoint for bart-large after being trained on the MultiNLI (MNLI) dataset.

Additional information about this model:
- The [bart-large](https://huggingface.co/facebook/bart-large) model page
- BART: [Denoising Sequence-to-Sequence Pre-training for Natural Language Generation, Translation, and Comprehension](https://arxiv.org/abs/1910.13461)

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text.ZeroShotClassification(
    procedure (Params: TZeroShotClassificationParam)
    begin
      Params.Model('facebook/bart-large-mnli');
      Params.Inputs('Hi, I recently bought a device from your company but it is not working as advertised and I would like to get reimbursed!');
      Params.Parameters(
        procedure (var Params: TZeroShotClassificationParameters)
        begin
          Params.CandidateLabels(['refund', 'legal', 'faq'])
        end);
    end,
    function : TAsynZeroShotClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

Other models that you can easily test.
- [valhalla/distilbart-mnli-12-9](https://huggingface.co/valhalla/distilbart-mnli-12-9)
- [MoritzLaurer/mDeBERTa-v3-base-mnli-xnli](https://huggingface.co/MoritzLaurer/mDeBERTa-v3-base-mnli-xnli)

<br/>

## Token Classification

For more details about the `token-classification` task, check out its [dedicated page](https://huggingface.co/tasks/token-classification)! You will find examples and related materials.

>[!NOTE]
> In the field of `Zero-shot classification`, over 20,755 pre-trained models are available. 
>

[FacebookAI/xlm-roberta-large-finetuned-conll03-english](https://huggingface.co/FacebookAI/xlm-roberta-large-finetuned-conll03-english) <br/>
The model can be used for token classification, a natural language understanding task in which a label is assigned to some tokens in a text. <br/>
See [associated paper](https://arxiv.org/abs/1911.02116)

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text.TokenClassification(
    procedure (Params: TTokenClassificationParam)
    begin
      Params.Model('FacebookAI/xlm-roberta-large-finetuned-conll03-english');
      //Params.Model('dslim/bert-base-NER');  //Can be used too
      Params.Inputs('My name is Sarah Jessica Parker but you can call me Jessica');
    end,
    function : TAsynTokenClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Question Answering

For more details about the `question-answering` task, check out its [dedicated page](https://huggingface.co/tasks/question-answering)! You will find examples and related materials.

>[!NOTE]
> In the field of `Question Answering`, over 12,683 pre-trained models are available. 
>

[deepset/roberta-base-squad2](https://huggingface.co/deepset/roberta-base-squad2) <br/>
This is the [roberta-base model](https://huggingface.co/FacebookAI/roberta-base), fine-tuned using the [SQuAD2.0 dataset](https://huggingface.co/datasets/rajpurkar/squad_v2). It's been trained on question-answer pairs, including unanswerable questions, for the task of Extractive Question Answering. <br/>
See [associated paper](https://arxiv.org/abs/1907.11692)

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text.QuestionAnswering(
    procedure (Params: TQuestionAnsweringParam)
    begin
      Params.Model('deepset/roberta-base-squad2');
      Params.Inputs('What is my name?', 'My name is Clara and I live in Berkeley.');
      Params.Parameters(
        procedure (var Params: TQuestionAnsweringParameters)
        begin
          Params.TopK(3);
        end);
    end,
    function : TAsynQuestionAnswering
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Table Question Answering

For more details about the `table-question-answering` task, check out its [dedicated page](https://huggingface.co/tasks/table-question-answering)! You will find examples and related materials.

>[!NOTE]
> In the field of `Table Question Answering`, over 133 pre-trained models are available. 
>

<br/>

[google/tapas-base-finetuned-wtq](https://huggingface.co/google/tapas-base-finetuned-wtq) <br/>
[TAPAS](https://github.com/google-research/tapas) is a BERT-like transformers model pretrained on a large corpus of English data from Wikipedia in a self-supervised fashion. This means it was pretrained on the raw tables and associated texts only, with no humans labelling them in any way (which is why it can use lots of publicly available data) with an automatic process to generate inputs and labels from those texts. 


**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text.TableQuestionAnswering(
    procedure (Params: TTableQAParam)
    begin
      Params.Model('google/tapas-base-finetuned-wtq');
      Params.Inputs(
        'How many stars does the tokenizers repository have?',
        [ TRow.Create('Repository', ['Transformers', 'Datasets', 'Tokenizers']),
          TRow.Create('Stars', ['36542', '4512', '3934']),
          TRow.Create('Contributors', ['651', '77', '34']),
          TRow.Create('Programming language',
             [ 'Python',
               'Python',
               'Rust, Python and NodeJS'
             ])
        ]);
    end,
    function : TAsynTableQA
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Fill-mask

For more details about the `fill-mask` task, check out its [dedicated page](https://huggingface.co/tasks/fill-mask)! You will find examples and related materials.

>[!NOTE]
> In the field of `Fill-mask`, over 13,570 pre-trained models are available. 
>

[google-bert/bert-base-uncased](https://huggingface.co/google-bert/bert-base-uncased) <br/>
Pretrained model on English language using a masked language modeling (MLM) objective. It was introduced in [this paper](https://arxiv.org/abs/1810.04805) and first released in [this repository](https://github.com/google-research/bert). This model is uncased: it does not make a difference between english and English.

<br/>


**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.API.WaitForModel := True;

  HuggingFace.Mask.Fill(
    procedure (Params: TMaskParam)
    begin
      Params.Model('google-bert/bert-base-uncased');
      Params.Inputs('The answer to the universe is [MASK].');
      Params.Parameters(['infinite', 'big', 'amazing', 'no', '42']);
    end,
    function : TAsynMask
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Text Classification

For more details about the `text-classification` task, check out its [dedicated page](https://huggingface.co/tasks/text-classification)! You will find examples and related materials.

>[!NOTE]
> In the field of `Text Classification`, over 77,280 pre-trained models are available. 
>

<br/>

[distilbert/distilbert-base-uncased-finetuned-sst-2-english](https://huggingface.co/distilbert/distilbert-base-uncased-finetuned-sst-2-english) <br/>
This model is a fine-tune checkpoint of DistilBERT-base-uncased, fine-tuned on SST-2. This model reaches an accuracy of 91.3 on the dev set (for comparison, Bert bert-base-uncased version reaches an accuracy of 92.7). <br/>
For more details about DistilBERT, we encourage to check out this [model card](https://huggingface.co/distilbert/distilbert-base-uncased).

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text.TextClassification(
    procedure (Params: TTextClassificationParam)
    begin
      Params.Model('distilbert/distilbert-base-uncased-finetuned-sst-2-english');
      Params.Inputs('I like you. I love you.');
    end,
    function : TAsynTextClassification
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```
This code example returns positive or negative depending on the meaning of the prompt.

- Use the model : [papluca/xlm-roberta-base-language-detection](https://huggingface.co/papluca/xlm-roberta-base-language-detection) as a language detector.
- Use the model: [cardiffnlp/twitter-roberta-base-sentiment-latest](https://huggingface.co/cardiffnlp/twitter-roberta-base-sentiment-latest) for sentiment analysis.

<br/>

## Summarization

Summarization is the task of producing a shorter version of a document while preserving its important information. Some models can extract text from the original input, while other models can generate entirely new text.

For more details about the `summarization` task, check out its [dedicated page](https://huggingface.co/tasks/summarization)! You will find examples and related materials.

>[!NOTE]
> In the field of `Summarization`, over 2,130 pre-trained models are available. 
>

<br/>

[facebook/bart-large-cnn](https://huggingface.co/facebook/bart-large-cnn) <br/>
BART is a transformer encoder-encoder (seq2seq) model with a bidirectional (BERT-like) encoder and an autoregressive (GPT-like) decoder. BART is pre-trained by (1) corrupting text with an arbitrary noising function, and (2) learning a model to reconstruct the original text.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.WaitForModel := True;

  HuggingFace.Text.Summarization(
    procedure (Params: TSummarizationParam)
    begin
      Params.Model('facebook/bart-large-cnn');
      Params.Inputs('The tower is 324 metres (1,063 ft) tall, about the same height as an 81-storey building, and the tallest structure in Paris. Its base is square, measuring 125 metres (410 ft) on each side. During its construction, the Eiffel Tower surpassed the Washington Monument to become the tallest man-made structure in the world, a title it held for 41 years until the Chrysler Building in New York City was finished in 1930. It was the first structure to reach a height of 300 metres. Due to the addition of a broadcasting aerial at the top of the tower in 1957, it is now taller than the Chrysler Building by 5.2 metres (17 ft). Excluding transmitters, the Eiffel Tower is the second tallest free-standing structure in France after the Millau Viaduct.');
    end,
    function : TAsynSummarization
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

# Common Ground Functionalities Across API Ecosystems

In the previous chapter, **Exploration Journey**, I walked through the unique features of `Hugging Face Hub APIs`, focusing on what makes them stand out. As I kept exploring, I noticed some strong overlaps with other platforms like `OpenAI`, `Anthropic`, and `Gemini`. That’s where Common Ground comes in. This chapter is about zooming out to look at those shared functionalities and seeing how these ecosystems stack up against each other. By focusing on what they have in common, we can get a clearer picture of the API landscape as a whole.

<br/>

## Embeddings

Feature extraction is the task of converting a text into a vector (often called “embedding”).

**Example applications:**
- Retrieving the most relevant documents for a query (for RAG applications).
- Reranking a list of documents based on their similarity to a query.
- Calculating the similarity between two sentences.

For more details about the `Embeddings` task, check out its [dedicated page](https://huggingface.co/tasks/feature-extraction)! You will find examples and related materials.

>[!NOTE]
> In the field of `Embeddings` over 7,400 pre-trained models are available. 
>

<br/>

[mixedbread-ai/mxbai-embed-large-v1](https://huggingface.co/mixedbread-ai/mxbai-embed-large-v1) : Produce sentence embeddings.

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.API.WaitForModel := True;

  HuggingFace.Embeddings.Create(
    procedure (Params: TEmbeddingParams)
    begin
      Params.Model('mixedbread-ai/mxbai-embed-large-v1');
      Params.Inputs('Today is a sunny day and I will get some ice cream.');
    end,
    function : TAsynEmbeddings
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Chat

Generate responses in a conversational context using a list of messages as input. This capability supports both conversational Language Models (LLMs) and Vision-Language Models (VLMs), bridging text-based and `image-to-text` functionalities. It is a specialized subtask within [`text generation`](https://huggingface.co/docs/api-inference/tasks/text-generation) and [`image-text-to-text`](https://huggingface.co/docs/api-inference/tasks/image-text-to-text) processing.

Recommended Models :

Conversational Large Language Models (LLMs)
- [google/gemma-2-2b-it](https://huggingface.co/google/gemma-2-2b-it): A robust text-generation model optimized for instruction following.
- [meta-llama/Meta-Llama-3.1-8B-Instruct](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct): A highly capable model for generating text and adhering to instructions.
- [microsoft/Phi-3-mini-4k-instruct](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct): A compact yet efficient text-generation model.
- [Qwen/Qwen2.5-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-7B-Instruct): A reliable model for text generation and instruction compliance.

Conversational Vision-Language Models (VLMs)
- [meta-llama/Llama-3.2-11B-Vision-Instruct](https://huggingface.co/meta-llama/Llama-3.2-11B-Vision-Instruct): A powerful vision-language model with excellent capabilities in visual comprehension and reasoning.
- [Qwen/Qwen2-VL-7B-Instruct](https://huggingface.co/Qwen/Qwen2-VL-7B-Instruct): A strong model designed for image-text-to-text tasks.

<br/>

### Multi Turn Conversation

Generate text based on a prompt. For more details about the `text-generation` task, check out its [dedicated page](https://huggingface.co/tasks/text-generation)! You will find examples and related materials.

>[!NOTE]
> In the field of `text-generation` over 163,600 pre-trained models are available. 
>

**Synchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.UseCache := False;

  var Chat := HuggingFace.Chat.Completion(
    procedure (Params: TChatPayload)
    begin
      Params.Model('microsoft/Phi-3-mini-4k-instruct');
      Params.Messages([
         TPayload.User('Hello'),
         TPayload.Assistant('Great to meet you. What would you like to know?'),
         TPayload.User('I have two dogs in my house. How many paws are in my house?')
      ]);
      Params.MaxTokens(1024);
    end);
  try
    Display(Memo1, Chat);
  finally
    Chat.Free;
  end;
```

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.UseCache := False;

  HuggingFace.Chat.Completion(
    procedure (Params: TChatPayload)
    begin
      Params.Model('microsoft/Phi-3-mini-4k-instruct');
      Params.Messages([
         TPayload.User('Hello'),
         TPayload.Assistant('Great to meet you. What would you like to know?'),
         TPayload.User('I have two dogs in my house. How many paws are in my house?')
      ]);
      Params.MaxTokens(1024);
    end,
    function : TAsynChat
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Streamed Multi Turn Conversation

**Synchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 
  
  HuggingFace.UseCache := False;

  HuggingFace.Chat.CompletionStream(
    procedure (Params: TChatPayload)
    begin
      Params.Model('microsoft/Phi-3.5-mini-instruct');
      Params.Messages([
         TPayload.User('Hello'),
         TPayload.Assistant('Great to meet you. What would you like to know?'),
         TPayload.User('I have two dogs in my house. How many paws are in my house?')
      ]);
      Params.Stream(True);
      Params.MaxTokens(1024);
    end,
    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    begin
      if Assigned(Chat) and not IsDone then
        begin
          DisplayStream(HFTutorial, Chat);
          Application.ProcessMessages;
        end;
    end);
```

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.UseCache := False;

  HuggingFace.Chat.CompletionStream(
    procedure (Params: TChatPayload)
    begin
      Params.Model('microsoft/Phi-3.5-mini-instruct');
      Params.Messages([
         TPayload.User('Hello'),
         TPayload.Assistant('Great to meet you. What would you like to know?'),
         TPayload.User('I have two dogs in my house. How many paws are in my house?')
      ]);
      Params.Stream(True);
      Params.MaxTokens(1024);
    end,
    function : TAsynChatStream
    begin
      Result.Sender := HFTutorial;
      Result.OnProgress := DisplayStream;
      Result.OnError := DisplayStream;
    end);  
```

<br/>

### Vision

Models that combine image and text inputs, often referred to as `vision-language` models (VLMs), generate text outputs based on both an image and a text prompt. Unlike traditional `image-to-text` models, which are primarily designed for specific tasks like image captioning, VLMs incorporate an additional layer of versatility by accepting text prompts. Some of these models are even trained to process entire conversations as input, enabling a broader range of applications.

For more details about the `image-text-to-text` task, check out its [dedicated page](https://huggingface.co/tasks/image-text-to-text)! You will find examples and related materials.

>[!NOTE]
> In the field of `image-text-to-text` over 5,750 pre-trained models are available. 
>

<br/>

**Synchronously streamed code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.UseCache := False;
  var ImageFilePath := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg';

  HuggingFace.Chat.CompletionStream(
    procedure (Params: TChatPayload)
    begin
      Params.Model('meta-llama/Llama-3.2-11B-Vision-Instruct');
      Params.Messages([TPayload.User('Describe the image ?', [ImageFilePath])]);
      Params.Stream(True);
      Params.MaxTokens(1024);
    end,
    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    begin
      if Assigned(Chat) and not IsDone then
        begin
          DisplayStream(HFTutorial, Chat);
          Application.ProcessMessages;
        end;
    end);
```

<br/>

**Asynchronously streamed code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial; 

  HuggingFace.UseCache := False;
  var ImageFilePath := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg';
  
    HuggingFace.Chat.CompletionStream(
    procedure (Params: TChatPayload)
    begin
      Params.Model('meta-llama/Llama-3.2-11B-Vision-Instruct');
      Params.Messages([TPayload.User('Describe the image ?', [ImageFilePath])]);
      Params.Stream(True);
      Params.MaxTokens(1024);
    end,
    function : TAsynChatStream
    begin
      Result.Sender := HFTutorial;
      Result.OnProgress := DisplayStream;
      Result.OnError := DisplayStream;
    end);
```

<br/>

### Use tools

What is the weather in Paris ?

The tool schema used :
```Json
  {
    "type": "object",
    "properties": {
         "location": {
             "type": "string",
             "description": "The city and department, e.g. Marseille, 13"
         },
         "unit": {
             "type": "string",
             "enum": ["celsius", "fahrenheit"]
         }
     },
     "required": ["location"]
  }
```

<br/>

1. We will use the `TWeatherReportFunction` plugin defined in the `HuggingFace.Functions.Example` unit.

```Delphi
  var Weather: IFunctionCore := TWeatherReportFunction.Create;
```

2. We then define a method to display the result of the query using the `Weather` tool.

```Delphi
procedure TMyForm.FuncExecuteStream(Sender: TObject; Text: string);
begin
  HuggingFace.WaitForModel := True;
  HuggingFace.UseCache := False;
  HuggingFace.Chat.CompletionStream(
    procedure (Params: TChatPayload)
    begin
      Params.Model('mistralai/Mixtral-8x7B-Instruct-v0.1');
      Params.Messages([
        TPayload.System('You are a fun and entertaining weather presenter.'),
        TPayload.User(Text)]);
      Params.Stream(True);
      Params.MaxTokens(1024);
    end,
    function : TAsynChatStream
    begin
      Result.Sender := HFTutorial;
      Result.OnProgress := DisplayStream;
      Result.OnError := DisplayStream;
    end);
end;
```

3. Building the query using the `Weather` tool

**Synchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial, HuggingFace.Functions.Example; 

  HuggingFace.WaitForModel := True;
  var Weather: IFunctionCore := TWeatherReportFunction.Create;
  HFTutorial.Func := Weather;
  HFTutorial.FuncProc := FuncExecuteStream;

  var Chat := HuggingFace.Chat.Completion(
    procedure (Params: TChatPayload)
    begin
      Params.Model('mistralai/Mixtral-8x7B-Instruct-v0.1');
      Params.Messages([TPayload.User('What is the weather in Paris ?')]);
      Params.Tools([Weather]);
      Params.MaxTokens(1024);
    end);
  try
    Display(Memo1, Chat);
  finally
    Chat.Free;
  end;
```

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial, HuggingFace.Functions.Example; 

  HuggingFace.WaitForModel := True;
  var Weather: IFunctionCore := TWeatherReportFunction.Create;
  HFTutorial.Func := Weather;
  HFTutorial.FuncProc := FuncExecuteStream;

  HuggingFace.Chat.Completion(
    procedure (Params: TChatPayload)
    begin
      Params.Model('mistralai/Mixtral-8x7B-Instruct-v0.1');
      Params.Messages([TPayload.User('What is the weather in Paris ?')]);
      Params.Tools([Weather]);
      Params.MaxTokens(1024);
    end,
    function : TAsynChat
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Text Generation

Generate text based on a prompt.

If you are interested in a Chat Completion task, which generates a response based on a list of messages, check out the [`chat-completion`](#Chat) task.

For more details about the `text-generation` task, check out its [dedicated page](https://huggingface.co/tasks/text-generation)! You will find examples and related materials.

<br/>

**Synchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HuggingFace.WaitForModel := True;
  HuggingFace.UseCache := False;

  var Generation := HuggingFace.Text.Generation(
    procedure (Params: TTextGenerationParam)
    begin
      Params.Model('google/gemma-2-2b-it');
      Params.Inputs('Can you please let us know more details about your');
      Params.Parameters(
        procedure (var Params: TTextGenerationParameters)
        begin
          Params.MaxNewTokens(1024);
          Params.DoSample(True);
          Params.DecoderInputDetails(True);
        end);
    end);
  try
    Display(HFTutorial, Generation);
  finally
    Generation.Free;
  end;
```

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HuggingFace.WaitForModel := True;
  HuggingFace.UseCache := False;

  HuggingFace.Text.Generation(
    procedure (Params: TTextGenerationParam)
    begin
      Params.Model('google/gemma-2-2b-it');
      Params.Inputs('Can you please let us know more details about your');
      Params.Parameters(
        procedure (var Params: TTextGenerationParameters)
        begin
          Params.MaxNewTokens(1024);
          Params.DoSample(True);
          Params.DecoderInputDetails(True);
        end);
    end,
    function : TAsynTextGeneration
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

**Asynchronously streamed code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HuggingFace.WaitForModel := True;
  HuggingFace.UseCache := False;

  HuggingFace.Text.GenerationStream(
    procedure (Params: TTextGenerationParam)
    begin
      Params.Model('google/gemma-2-2b-it');
      Params.Inputs('Can you please let us know more details about your');
      Params.Stream(True);
    end,
    function : TAsynTextGenerationStream
    begin
      Result.Sender := HFTutorial;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
    end);
```

<br/>

## Translation

Translation is the task of converting text from one language to another.

For more details about the `translation` task, check out its [dedicated page](https://huggingface.co/tasks/translation)! You will find examples and related materials.

>[!NOTE]
> In the field of `translation` over 5,079 pre-trained models are available. 
>

<br>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HuggingFace.WaitForModel := True;

  //French to english translation
  HuggingFace.Text.Translation(
    procedure (Params: TTranslationParam)
    begin
      Params.Model('Helsinki-NLP/opus-mt-fr-en');
      Params.Inputs('Je n''aurais pas dû abuser du chocolat, je crois que je vais le regretter.');
      Params.Parameters(
        procedure (var Params: TTranslationParameters)
        begin
          Params.SrcLang('french');
          Params.TgtLang('english');
        end);
    end,
    function : TAsynTranslation
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Image Generation

Generate an image based on a given text prompt.

For more details about the `text-to-image` task, check out its [dedicated page](https://huggingface.co/tasks/text-to-image)! You will find examples and related materials.

>[!NOTE]
> In the field of `text-to-image` over 50,539 pre-trained models are available. 
>

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HuggingFace.WaitForModel := True;
  HuggingFace.API.UseCache := False;
  HFTutorial.FileName := 'Quarter.png';

  HuggingFace.Text.TextToImage(
    procedure (Params: TTextToImageParam)
    begin
      Params.Model('stabilityai/stable-diffusion-3-medium-diffusers');
      Params.Inputs('A quarter dollar coin placed on a wooden floor in a close-up view');
    end,
    function : TAsynTextToImage
    begin
      Result.Sender := HFTutorial;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Text-to-Speech

Convert a text to an audio speech.

>[!NOTE]
> In the field of `text-to-speech` over 2,273 pre-trained models are available. 
>

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HFTutorial.FileName := 'temp.mp3';
  HuggingFace.WaitForModel := True;

  HuggingFace.Text.TextToSpeech(
    procedure (Params: TTextToSpeechParam)
    begin
      Params.Model('facebook/mms-tts-eng');
      Params.Inputs('Hello and welcome. It''s nice to meet you.');
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

## Automatic Speech Recognition

Automatic Speech Recognition (ASR), often referred to as Speech to Text (STT), involves converting spoken audio into written text.

Use Cases:
- Converting a podcast into text format
- Creating a voice assistant system
- Producing subtitles for video content

For more details about the `automatic-speech-recognition` task, check out its [dedicated page](https://huggingface.co/tasks/automatic-speech-recognition)! You will find examples and related materials.

>[!NOTE]
> In the field of `speech-to-text` over 21,386 pre-trained models are available. 
>

Suggested Models:
- [openai/whisper-large-v3](https://huggingface.co/openai/whisper-large-v3): An advanced ASR model developed by OpenAI.
- [nvidia/canary-1b](https://huggingface.co/nvidia/canary-1b): A robust model supporting multilingual ASR and speech translation, designed by Nvidia.
- [pyannote/speaker-diarization-3.1](https://huggingface.co/pyannote/speaker-diarization-3.1): A highly effective model for distinguishing and labeling different speakers in audio recordings.

<br/>

**Asynchronously code example**

```Pascal
// uses HuggingFace, HuggingFace.Types, HuggingFace.Aggregator, FMX.HuggingFace.Tutorial;

  HuggingFace.API.WaitForModel := True;

  HuggingFace.Audio.AudioToText(
    procedure (Params: TAudioToTextParam)
    begin
      Params.Model('openai/whisper-large-v3-turbo');
      Params.Inputs('SpeechRecorded.wav');
      Params.GenerationParameters(
        procedure (var Params: TGenerationParameters)
        begin
          Params.MaxLength(10);
        end);
    end,
    function : TAsynAudioToText
    begin
      Result.Sender := HFTutorial;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```
Remark: To run this example, you must first record some speech text in a file named `SpeechRecorded.wav`.

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

<br/>

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.